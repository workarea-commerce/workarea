require 'workarea/testing/engine'

module Workarea
  class OverrideGenerator < Rails::Generators::Base

    desc File.read(File.expand_path('../USAGE', __FILE__))

    argument :type, type: :string, required: true
    argument :path, type: :string, required: true

    def override
      directory = if type == 'layouts'
                    'views/layouts'
                  elsif type.in?(%w(javascripts stylesheets images fonts))
                    "assets/#{type}"
                  else
                    type
                  end


      [
        Workarea::Plugin.installed,
        Workarea::Core,
        Workarea::Testing
      ].flatten.each do |plugin|
        puts "Generating #{type} for #{plugin.to_s.demodulize.titleize.downcase}..."

        root = plugin.const_get(:Engine).root

        self.class.class_eval("def self.source_root; '#{root}'; end;")

        relative_path = "app/#{directory}/#{path}"
        full_path = "#{root}/#{relative_path}"

        if File.directory?(full_path)
          directory(
            full_path,
            relative_path
          )
        elsif File.file?(full_path)
          copy_file(
            full_path,
            relative_path
          )

          copy_files_with_matching_names(
            full_path,
            relative_path
          )
        end
      end
    end

    private

    def copy_files_with_matching_names(full_path, relative_path)
      segments = full_path.split('/')
      file_name = segments.pop
      source_directory = segments.join('/')
      destination_directory = relative_path.split('/')[0..-2].join('/')

      if File.directory?(source_directory)
        # loop through structure of name to determine if other files
        # in the directory have the same name but different file format
        # and copy file if matched.
        #
        file_name.split('.').inject('') do |name, segment|
          name += "#{segment}."
          file_regexp = /\A#{Regexp.quote(name)}/

          Dir.foreach(source_directory) do |file|
            if file != file_name && file =~ file_regexp
              copy_file(
                "#{source_directory}/#{file}",
                "#{destination_directory}/#{file}"
              )
            end
          end

          name
        end
      end
    end
  end
end
