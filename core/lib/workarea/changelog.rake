namespace :workarea do
  desc 'Generate a CHANGELOG.md file based on Git history'
  task changelog: :environment do
    # Ensure directory
    if Dir['.git'].empty?
      raise "the changelog task must be run from this repo's root directory"
    end

    # set up & capture git log
    from =
      if `git tag`.empty?
        `git rev-list --max-parents=0 HEAD`.strip
      else
        `git describe --tags --abbrev=0`.strip
      end
    git_log_format = '%H[/PIECE]%s[/PIECE]%b[/PIECE]%an[/ENTRY]'
    log = `git log #{from}..HEAD --pretty=format:'#{git_log_format}' --no-merges`

    # assumes only one gemspec in project root
    gem = Gem::Specification.load(Dir['./*.gemspec'].first)
    gem_name = gem.name.tr('_', '-').split('-').map(&:capitalize).join(' ')
    gem_version = gem.version.version

    # Iterate through each commit in the log, cataloging entries and reverts
    entries = {}
    reverts = []
    log.split('[/ENTRY]').each do |commit|
      pieces = commit.split('[/PIECE]').map(&:strip)
      sha, subject, body, author = pieces

      next if subject =~ /update changelog/i
      next if subject =~ /release version/i
      next if body =~ /no changelog/i

      entries[sha] = {
        subject: subject,
        body: body,
        author: author
      }

      if subject.start_with?('Revert')
        reverts << body.match(/[a-f0-9]{40}/)
        reverts << sha
      end
    end

    # Remove revert commits from log entries
    reverts.each { |key| entries.delete key }

    # guard against empty changelog
    if entries.empty?
      raise "the generated changelog must have at least one entry"
    end

    # set message title
    message = []
    message << "#{gem_name} #{gem_version} (#{Date.today})"
    message << '-' * 80 + "\n"

    # loop through all entries, templetizing their contents
    entries.each do |sha, entry|
      message << "*   #{entry[:subject]}\n"
      entry[:body].each_line do |line|
        if line.strip.empty?
          message << ''
        else
          message << "    #{line.strip}"
        end
      end
      message << "    #{entry[:author]}\n"
    end

    # ensure and append to changelog
    FileUtils.touch('CHANGELOG.md')

    tempfile = Tempfile.new
    changelog = File.expand_path('./CHANGELOG.md')

    File.open(tempfile, 'a') do |file|
      file << message.join("\n")
      file << "\n\n\n"
      file << File.read(changelog)
    end

    FileUtils.mv(tempfile, changelog)
  end
end
