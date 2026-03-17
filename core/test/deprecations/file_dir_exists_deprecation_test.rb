require 'test_helper'

module Workarea
  module Deprecations
    class FileDirExistsDeprecationTest < Workarea::TestCase
      def test_file_and_dir_exists_are_not_used
        repo_root = Pathname.new(__dir__).join('..', '..', '..').expand_path
        pattern = /\b(?:File|Dir)\.exists\?\b/

        files = Dir.glob(repo_root.join('{core,admin,storefront}/**/*.{rb,rake,erb}').to_s)

        offenders = files.filter_map do |path|
          next unless File.file?(path)

          content = File.read(path)
          next unless content.match?(pattern)

          relative = Pathname.new(path).relative_path_from(repo_root)
          line_numbers = []
          content.each_line.with_index(1) { |line, i| line_numbers << i if line.match?(pattern) }

          "#{relative}:#{line_numbers.join(',')}"
        end

        assert(offenders.empty?, <<~MSG)
          Deprecated File.exists?/Dir.exists? usage detected. Replace with File.exist?/Dir.exist?.

          Offenders:
          #{offenders.join("\n")}
        MSG
      end
    end
  end
end
