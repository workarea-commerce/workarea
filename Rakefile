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
  # Run each gem's tests via its isolated Rake::TestTask subprocess target.
  #
  # Previously this task called Rails::TestUnit::Runner.rake_run with all gem
  # test paths in a single in-process Ruby invocation. That caused 99.6% setup
  # failures: every test file calls `require 'test_helper'`, but Ruby's require
  # cache returns the first match found in $LOAD_PATH.  With only 'core/test'
  # on the path, admin and storefront tests all booted core's dummy app (which
  # has neither engine installed), and setup transactions / fixtures failed.
  #
  # Each per-gem Rake::TestTask (core_test, admin_test, storefront_test) spawns
  # a fresh Ruby subprocess with only that gem's test/ directory on $LOAD_PATH,
  # so its own test_helper and dummy app are used — providing correct RAILS_ENV
  # propagation and isolated setup per engine.
  GEMS.each { |gem| Rake::Task["#{gem}_test"].invoke }
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
