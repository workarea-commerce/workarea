module Workarea
  module Storefront
    module ApplicationHelper
      def page_title(title_content = @title)
        title = [title_content, Workarea.config.site_name]
                  .reject(&:blank?)
                  .join(' - ')

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
    end
  end
end
