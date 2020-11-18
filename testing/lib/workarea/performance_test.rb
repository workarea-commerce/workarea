require 'benchmark'

module Workarea
  class PerformanceTest < ActionDispatch::IntegrationTest
    extend  TestCase::Decoration
    include TestCase::Configuration
    include TestCase::Workers
    include TestCase::SearchIndexing
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include TestCase::Encryption
    include TestCase::Geocoder
    include Factories
    include IntegrationTest::Configuration
    include IntegrationTest::Locales

    HEADER = %w(measurement created_at workarea rails ruby revision passed)

    setup :warmup_app
    teardown :reset_caching

    def warmup_app
      @controller_caching = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = true
      get '/'
    end

    def reset_caching
      ActionController::Base.perform_caching = @controller_caching
    end

    def run
      with_info_handler do
        time_it do
          capture_exceptions do
            pass && (return Minitest::Result.from(self)) unless ENV['PERF_TEST'] =~ /true/

            before_setup
            setup
            after_setup

            with_benchmarking { self.send self.name }
          end

          Minitest::Test::TEARDOWN_METHODS.each do |hook|
            capture_exceptions { self.send hook }
          end
        end
      end

      Minitest::Result.from(self) # per contract
    end

    def with_benchmarking(&block)
      result = Benchmark.measure { yield }
      previous_times = previous_run_measurements

      previous_times.each do |time|
        if time < result.real
          assert_in_epsilon(
            time,
            result.real,
            max_percentage_of_change,
            epsilon_failure_message
          )
        end
      end

      benchmark_file.puts(formatted_results(result))

    rescue Minitest::Assertion => e
      benchmark_file.puts(formatted_results(result, false))
      raise e
    ensure
      benchmark_file.close
    end

    private

    # Find previous run times. Finds x+2 number of times based on
    # configuration then removes the highest and lowest times to reduce
    # the standard deviation of typical run times.
    def previous_run_measurements
      rows = benchmark_file.to_a.reverse
      return [] unless rows.any?

      rows
        .select { |row| row['passed'].to_s =~ /true/ }
        .take(Workarea.config.performance_test_comparisons + 2)
        .map { |row| row.to_hash['measurement'].to_f }
        .sort[1...-1] || []
    end

    def benchmark_file
      return @benchmark_file if defined?(@benchmark_file)

      fname = output_filename
      new_file = !File.exist?(fname)
      FileUtils.mkdir_p(File.dirname(fname)) if new_file

      @benchmark_file = CSV.open(fname, 'a+b', headers: true)
      @benchmark_file.puts(HEADER) if new_file
      @benchmark_file
    end

    def output_filename
      path = ENV['WORKAREA_PERF_TEST_PATH'] ||
             Workarea.config.performance_test_output_path

      "#{path}/#{self.class.name.underscore}/#{self.name}.csv"
    end

    def formatted_results(benchmark, passed = true)
      [
        benchmark.real,
        Time.current.utc.xmlschema,
        Workarea::VERSION::STRING,
        Rails::VERSION::STRING,
        "#{RUBY_VERSION}.#{RUBY_PATCHLEVEL}",
        git_revision,
        passed
      ]
    end

    def git_revision
      `git branch -v` =~ /^\* (\S+)\s+(\S+)/ ? "#{$1}.#{$2}" : "n/a"
    end

    def epsilon_failure_message
      amount = max_percentage_of_change * 100
      "run took more than #{amount}% longer than the previous run"
    end

    def max_percentage_of_change
      Workarea.config.performance_test_max_percentage_of_change
    end
  end
end
