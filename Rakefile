require 'date'

require 'rake/testtask'
require File.expand_path('../core/lib/workarea/version', __FILE__)

load 'rails/test_unit/testing.rake'
load 'workarea/changelog.rake'
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
    paths <<  "#{gem}/test/performance/**/*_test.rb"
  end

  Rails::TestUnit::Runner.rake_run(paths)
end

desc "Release version #{Workarea::VERSION::STRING} of the gems"
task :release do
  component_gems = GEMS + %w(testing)
  host = "https://#{ENV['BUNDLE_GEMS__WORKAREA__COM']}@gems.workarea.com"

  #
  # Updating changelog
  #
  #
  Rake::Task["workarea:changelog"].execute
  system 'git add CHANGELOG.md'
  system 'git commit -m "Update CHANGELOG"'

  #
  # Build gem files
  #
  #
  puts 'Building gems...'
  component_gems.each do |gem|
    Dir.chdir("#{ROOT_DIR}/#{gem}")
    system "gem build workarea-#{gem}.gemspec"
  end

  Dir.chdir(ROOT_DIR)
  system "gem build workarea.gemspec"

  #
  # Push gem files
  #
  #
  puts 'Pushing gems...'
  component_gems.each do |gem|
    system "gem push #{gem}/workarea-#{gem}-#{Workarea::VERSION::STRING}.gem"
    system "gem push #{gem}/workarea-#{gem}-#{Workarea::VERSION::STRING}.gem --host #{host}"
  end
  system "gem push workarea-#{Workarea::VERSION::STRING}.gem"
  system "gem push workarea-#{Workarea::VERSION::STRING}.gem --host #{host}"

  #
  # Add tag & push to origin
  #
  #
  system 'Tagging git...'
  system "git tag -a v#{Workarea::VERSION::STRING} -m 'Tagging #{Workarea::VERSION::STRING}'"
  system "git push origin HEAD --follow-tags"

  #
  # Clean up
  #
  #
  puts 'Cleaning up...'
  component_gems.each do |gem|
    system "rm #{gem}/workarea-#{gem}-#{Workarea::VERSION::STRING}.gem"
  end

  system "rm workarea-#{Workarea::VERSION::STRING}.gem"

  puts "Success releasing #{Workarea::VERSION::STRING}!"
end
