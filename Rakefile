require 'date'

require 'rake/testtask'
require File.expand_path('../core/lib/workarea/version', __FILE__)

load 'rails/test_unit/testing.rake'
load 'workarea/release.rake'
load File.expand_path('../core/lib/tasks/services.rake', __FILE__)

GEMS = %w(core admin storefront)
ROOT_DIR = Dir.pwd

GEMS.each do |gem|
  Rake::TestTask.new("#{gem}_test") do |t|
    t.libs << "#{gem}/test"
    t.pattern = "#{gem}/test/**/*_test.rb"
    t.verbose = false
    t.warning = false
  end

  desc "Run #{gem} teaspoon tests"
  task "#{gem}_teaspoon" do
    Dir.chdir("#{ROOT_DIR}/#{gem}")
    system 'rake teaspoon'
    exit 1 unless $?.success?
  end
end

Rake::Task['test:db'].clear_comments
Rake::Task['test:system'].clear_comments
Rake::Task["test"].clear
desc 'Run tests for all gems'
task :test do
  require 'rails/test_unit/reporter'

  $: << 'core/test'
  Rails::TestUnitReporter.executable = 'bin/rails test'

  # Override this to print a command that we rerun the test on failure
  Rails::TestUnitReporter.class_eval do
    def format_rerun_snippet(result)
      location, line = result.method(result.name).source_location
      rel_path = relative_path_for(location)

      GEMS.each do |gem|
        if rel_path.include?(gem)
          return "cd #{gem} && bin/rails test #{rel_path}:#{line}"
        end
      end

      "#{executable} #{rel_path}:#{line}"
    end
  end

  Rails::TestUnit::Runner.rake_run(GEMS.map { |g| "#{g}/test" })
end

desc 'Run performance tests for all gems'
Rake::TestTask.new('performance_test') do |t|
  ENV['PERF_TEST'] = 'true'

  GEMS.each { |gem| t.libs << "#{gem}/test" }

  t.verbose = false
  t.warning = false
  t.test_files = FileList.new(
    *GEMS.map { |gem| "#{gem}/test/performance/**/*_test.rb" }
  )
end

task "performance_test_ci" do
  ENV['CI'] = 'true'
  ENV['JUNIT_PATH'] = "tmp/reports"
  ENV['PERF_TEST'] = 'true'

  paths = []

  GEMS.each do |gem|
    $: << "#{gem}/test"
    paths << "#{gem}/test/performance/**/*_test.rb"
  end

  Rails::TestUnit::Runner.rake_run(paths)
end

