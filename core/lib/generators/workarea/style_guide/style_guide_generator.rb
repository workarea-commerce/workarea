module Workarea
  module Generators
    class StyleGuideGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc File.read(File.expand_path('../USAGE', __FILE__))

      argument :engine, type: :string, required: true
      argument :section, type: :string, required: true
      argument :name, type: :string, required: true

      def style_guide
        @engine = engine.downcase.gsub(/[\s-]/, '_')
        @section = section.downcase.gsub(/[\s-]/, '_')
        @name = name.downcase.gsub(/[\s_]/, '-')
        @slug = @name.gsub('-', '_')

        template 'style_guide_partial.html.haml.erb', style_guide_file_path
      end

      private

      def style_guide_file_path
        "#{engine_path}/style_guides/#{partial_path}.html.haml"
      end

      def engine_path
        "app/views/workarea/#{@engine}"
      end

      def partial_path
        "#{@section}/_#{@slug}"
      end
    end
  end
end
