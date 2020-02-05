require 'active_support/inflector'

load 'workarea/changelog.rake'

namespace :workarea do
  desc "Release the next version of this gem"
  task :release, [:private] do |task, args|
    #
    # Devise current gem version
    #
    #
    version_file_path = Dir['**/version.rb'].reject { |p| p =~ /vendor/ }.first
    gem_namespace =
      version_file_path
        .split('lib/').last
        .split('/version').first
        .classify

    gem_name = gem_namespace.gsub(/::/, ' ')

    current_version = if gem_namespace == 'Workarea'
      "#{gem_namespace}::VERSION::STRING".constantize
    else
      "#{gem_namespace}::VERSION".constantize
    end

    #
    # Devise next gem version
    #
    #
    current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
    puts <<~MESSAGE
      You're about to release a new version of the #{gem_name} gem.

      The current version in the #{current_branch} branch is #{current_version}.

      Please provide the version that you'd like to release:
    MESSAGE

    next_version = STDIN.gets.chomp

    puts "Should I release #{next_version} from #{current_branch}? (Y/n)"
    answer = STDIN.gets.chomp
    answer = 'Y' if answer.empty?
    abort("Nothing to do") unless answer.casecmp?('Y')

    #
    # Update version.rb and CHANGELOG.md
    #
    #
    tempfile = Tempfile.new('version_temp.rb')
    File.open(version_file_path, 'r') do |file|
      file.each_line do |line|
        tempfile.puts line.include?(current_version) \
          ? line.gsub(current_version, next_version) \
          : line
      end
    end
    tempfile.close
    FileUtils.mv(tempfile.path, version_file_path)

    Rake::Task['workarea:changelog'].execute(
      gem_name: gem_name,
      gem_version: next_version
    )

    #
    # Tag release and push
    #
    #
    system <<~COMMAND
      git add CHANGELOG.md &&
      git add #{version_file_path} &&
      git commit -m 'Release version #{next_version}' &&
      git tag -a 'v#{next_version}' -m 'Tagging #{next_version}' &&
      git push origin HEAD --follow-tags
    COMMAND

    #
    # Build gems, push to hosts, and clean up
    #
    #
    hosts = ["https://#{ENV['BUNDLE_GEMS__WORKAREA__COM']}@gems.workarea.com"]
    hosts << "https://rubygems.org" unless args[:private]

    gemspec_file_paths = Dir['**/workarea*.gemspec']
    gemspec_file_paths.each { |path| system "gem build #{path}" }

    gem_file_paths = Dir['**/workarea*.gem']
    gem_file_paths.each do |path|
      hosts.each do |host|
        system <<~COMMAND
          gem push #{path} --host #{host} &&
          rm #{path}
        COMMAND
      end
    end

    puts <<~MESSAGE

      Rejoice! You've released #{gem_name} version #{next_version}!

    MESSAGE
  end
end
