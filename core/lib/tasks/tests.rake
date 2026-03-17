load 'rails/test_unit/testing.rake'

# Rails 7.2 removed Rails::TestUnit::Runner.rake_run.
# Provide a compatibility shim so tests run on both Rails 7.x and 7.2+.
module WorkareaTestRunner
  def self.run(test_paths)
    if Rails::TestUnit::Runner.respond_to?(:rake_run)
      # Rails < 7.2
      Rails::TestUnit::Runner.rake_run(test_paths)
    else
      # Rails 7.2+: load test files directly and let Minitest autorun handle them.
      test_files = Array(test_paths).flat_map do |path|
        path_str = path.to_s
        if File.directory?(path_str)
          Dir.glob("#{path_str}/**/*_test.rb")
        else
          [path_str]
        end
      end
      test_files.uniq.sort.each { |f| require File.expand_path(f) }
      require "active_support/testing/autorun"
    end
  end
end

namespace :workarea do
  task :prepare do
    $: << 'test'
  end

  desc 'Run workarea tests (with decorators)'
  task test: :prepare do
    roots = [Workarea::Core::Engine.root] +
              Workarea::Plugin.installed.map(&:root) +
              [Rails.root]

    WorkareaTestRunner.run(
      roots
        .map { |r| FileList["#{r}/test/**/*_test.rb"] }
        .reduce(&:+)
    )
  end

  desc 'Run workarea/core tests (with decorators)'
  task 'test:core' => :prepare do
    WorkareaTestRunner.run(["#{Workarea::Core::Engine.root}/test"])
  end

  desc 'Run decorated tests'
  task 'test:decorated' => :prepare do
    decorators = Dir.glob("test/**/*.#{Rails::Decorators.extension}")
    decorated = decorators.map do |file|
      file.gsub(".#{Rails::Decorators.extension}", '.rb')
    end

    roots = [Workarea::Core::Engine.root] +
              Workarea::Plugin.installed.map(&:root)

    WorkareaTestRunner.run(
      decorated.reduce([]) do |memo, relative_original|
        original = roots
          .map { |root| "#{root}/#{relative_original}" }
          .detect { |original_path| File.exist?(original_path) }
        if original.blank?
          raise <<~HEREDOC
          Problem:
            Can't find original test #{relative_original} for #{relative_original.gsub(/rb$/, Rails::Decorators.extension.to_s)}
          Summary:
            Test decorators need to have the same path as the orignal test.
          Resolution:
            Check that your test decoration has the right path and file name.
          HEREDOC
        end
        memo << original
      end
    )
  end

  desc 'Run all installed workarea plugin tests (with decorators)'
  task 'test:plugins' => :prepare do
    engines = Workarea::Plugin.installed.reject do |engine|
      %w(admin storefront).include?(engine.slug)
    end.map(&:root)

    WorkareaTestRunner.run(
      engines.map { |r| FileList["#{r}/test/**/*_test.rb"] }.reduce(&:+) || []
    )
  end

  desc 'Run all app specific tests'
  task 'test:app' => :prepare do
    WorkareaTestRunner.run(FileList["#{Rails.root}/test/**/*_test.rb"])
  end

  Workarea::Plugin.installed.each do |engine|
    desc "Run workarea #{engine.slug} tests (with decorators)"
    task "test:#{engine.slug}" => :prepare do
      WorkareaTestRunner.run(
        FileList[engine.root.join('test', '**', '*', '*_test.rb')]
      )
    end
  end

  desc 'Run workarea performance tests (with decorators)'
  task 'test:performance' => :prepare do
    roots = [Workarea::Core::Engine.root] +
              Workarea::Plugin.installed.map(&:root) +
              [Rails.root]

    ENV['PERF_TEST'] = 'true'
    WorkareaTestRunner.run(
      roots
        .map { |r| FileList["#{r}/test/performance/**/*_test.rb"] }
        .reduce(&:+)
    )
  end
end
