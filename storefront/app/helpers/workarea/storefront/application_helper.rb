module Workarea
  module Storefront
    module ApplicationHelper
      def page_title(title_content = @title)
        if title_content.present?
          title = t(
            'workarea.storefront.layouts.page_title_with_content',
            title_content: title_content,
            site_name: Workarea.config.site_name
          )
        else
          title = t('workarea.storefront.layouts.page_title',
            site_name: Workarea.config.site_name
          )
        end

        unless Rails.env.in?(%w(test development production))
          title = "[#{Rails.env.upcase}] #{title}"
        end

        title
      end

      def add_css(css)
        return unless css.present?

        content_for(:css) do
          content_tag(:style, css.html_safe)
        end
      end

      def add_javascript(js)
        return unless js.present?

        content_for(:javascript) do
          content_tag(:script, js.html_safe)
        end
      end

      def add_head_content(content)
        return unless content.present?

        content_for(:head_content) do
          content.html_safe
        end
      end

      def flash_messages
        flash.keys.inject('') do |memo, name|
          msg = flash[name]
          html_options = {
            data: {
              analytics: {
                event: 'flashMessage',
                payload: { type: name }
              }.to_json
            }
          }

          if msg.is_a?(Enumerable)
            msg.each do |message|
              if message.is_a?(String)
                memo << render_message(name, message, html_options)
              end
            end
          elsif msg.is_a?(String)
            memo << render_message(name, msg, html_options)
          end

          flash.delete(name)
          memo
        end.html_safe
      end

      def render_message(type, message = nil, html_options = {}, &block)
        html_options = message if message.is_a?(Hash)
        message = capture(&block) if block_given?

        html_options[:class] = "message--#{type.systemize}"
        render('workarea/storefront/shared/message', type: type.systemize, message: message, html_options: html_options)
      end

      def loading_indicator(message, *modifiers)
        css_classes = modifiers.map { |c| "loading--#{c}" }.join(' ')
        content_tag(:span, message, class: "loading loading--inline #{css_classes}")
      end

      def optional_field(prompt, *fields, &block)
        return capture(&block) if fields.any?(&:present?)
        content_tag(:div, capture(&block), { class: 'hidden-if-js-enabled',
                                             data: { optional_field: prompt } })
      end

      def lazy_image_tag(source, options = {})
        options = options.symbolize_keys

        check_for_image_tag_errors(options)
        skip_pipeline = options.delete(:skip_pipeline)

        if options[:srcset] && !options[:srcset].is_a?(String)
          options[:srcset] = options[:srcset].map do |src_path, size|
            src_path = path_to_image(src_path, skip_pipeline: skip_pipeline)
            "#{src_path} #{size}"
          end.join(", ")
        end

        options[:width], options[:height] = extract_dimensions(options.delete(:size)) if options[:size]

        lazy_options = options.deep_dup
        image_source = resolve_image_source(source, skip_pipeline)

        lazy_options[:data] ||= {}
        lazy_options[:data][:lazy_image] = image_source

        lazy_options[:class] ||= ''
        lazy_options[:class] << ' lazy-image'

        tag
          .noscript(tag.img(options.merge(src: image_source)))
          .concat(tag.img(lazy_options))
      end
    end
  end
end
