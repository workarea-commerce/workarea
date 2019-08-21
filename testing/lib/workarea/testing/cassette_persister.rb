module Workarea
  module Testing
    module CassettePersister
      extend self

      def [](file_name)
        path = absolute_path_to_file(file_name)

        if path.nil?
          nil
        else
          File.binread(path)
        end
      end

      def []=(file_name, content)
        directory = if TestCase.running_in_dummy_app?
                      Rails.root.join('..', 'vcr_cassettes')
                    else
                      Rails.root.join('test', 'vcr_cassettes')
                    end

        path = directory.join(file_name)
        directory = File.dirname(path)
        FileUtils.mkdir_p(directory) unless File.exist?(directory)
        File.binwrite(path, content)
      end

      def absolute_path_to_file(file_name)
        roots = [Rails.root] +
                  Workarea::Plugin.installed.map(&:root) +
                  [Workarea::Core::Engine.root]

        roots
          .map { |root| root.join('test', 'vcr_cassettes', file_name) }
          .detect { |path| File.exist?(path) }
      end
    end
  end
end
