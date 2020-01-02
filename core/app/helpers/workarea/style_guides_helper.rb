module Workarea
  module StyleGuidesHelper
    class Partials
      def initialize(root, scope, category)
        @root = root
        @scope = scope
        @category = category
      end

      def pattern
        "#{@root}/app/views/workarea/#{@scope}/style_guides/#{@category}/*.html*"
      end

      def to_a
        Dir[pattern]
          .map { |path| name_from(path) }
          .uniq
          .sort
      end

      def name_from(path)
        path
          .gsub("#{@root}/app/views/", '')
          .gsub(/\/_(.+)\.html.*/, '/\1')
      end
    end

    def partial_paths_for(category)
      scope = engine.module_parent.to_s.demodulize.downcase

      style_guide_engines.map { |e| Partials.new(e.root, scope, category).to_a }
        .flatten
        .uniq
    end

    def link_to_style_guide(category, partial, dialog = false, custom_anchor = nil)
      parent = partial.split('__').first
      anchor = partial.include?('__') ? partial.dasherize : custom_anchor
      text = custom_anchor.present? ? custom_anchor : partial.dasherize

      link_to(
        text,
        style_guide_path(
          category,
          parent,
          anchor: anchor,
          locale: params[:locale] # included to fix tests
        ),
        data: dialog ? { dialog_button: '' } : nil,
        class: style_guide_link_class(partial)
      )
    end

    def style_guide_icons
      style_guide_engines
        .map { |e| Dir["#{e.root}/app/assets/images/workarea/#{parent_module.slug}/**/icons/**/*.svg"].uniq.sort }
        .flatten
        .reverse
        .uniq { |path| File.basename(path) }
        .sort_by { |path| File.basename(path) }
    end


    def style_guide_link_class(partial)
      classes = ['style-guide__link']
      classes << 'style-guide__link--active' if partial == params[:id]
      classes.join(' ')
    end

    private

    def parent_module
      controller.class.module_parent
    end

    def engine
      engine ||= parent_module.const_get(:Engine)
    end

    def style_guide_engines
      [engine, Core::Engine, Rails.application, plugin_engines].flatten
    end

    def plugin_engines
      Workarea::Plugin.installed.reject { |e| e.in? [Workarea::Admin, Workarea::Storefront, Workarea::Core] }
    end
  end
end
