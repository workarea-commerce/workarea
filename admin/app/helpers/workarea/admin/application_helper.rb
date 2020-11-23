module Workarea
  module Admin
    module ApplicationHelper
      def page_title
        title = @page_title.presence || 'Workarea'

        unless Rails.env.in?(%w(test development production))
          title = "[#{Rails.env.upcase}] #{title}"
        end

        title
      end

      def sort_options(model)
        model.sorts.map do |sort|
          [sort.name, sort.slug]
        end
      end

      def hash_editing_value(value)
        CSV.generate_line(Array(value).flatten).strip
      end

      def hash_display_value(value)
        CSV.generate_line(Array(value).flatten, col_sep: ', ').strip
      end

      def render_summary_for(model)
        render "workarea/admin/#{model.model_name.route_key}/summary", model: model
      rescue ActionView::MissingTemplate
        render "workarea/admin/shared/summary", model: model
      end

      def generic_summary_type(model)
        model.class.name.gsub(/Workarea::/, '').gsub(/::/, ' ')
      end

      def render_cards_for(model, active = nil)
        render(
          "workarea/admin/#{model.model_name.route_key}/cards",
          model: model,
          active: active
        )

      rescue ActionView::MissingTemplate
        # It's ok if there aren't any cards to render
      end

      def render_aux_navigation_for(model, options = {})
        render(
          "workarea/admin/#{model.model_name.route_key}/aux_navigation",
          options.merge(model: model)
        )

      rescue ActionView::MissingTemplate
        # It's ok if there isn't any auxilliary nav to render
      end

      def card_classes(type, active = nil)
        classes = []
        classes << "card--#{type.to_s.dasherize}"
        classes << 'card--active' if type == active
        classes << 'card--button' if active.present?

        classes.join(' ')
      end

      def user_name_type(user)
        if user.name == user.email
          t('workarea.admin.users.name_types.email')
        else
          t('workarea.admin.users.name_types.name')
        end
      end

      def show_filters_reset?
        params.except(:controller, :action, :utf8, :sort).present?
      end

      def path_with_query_string(path, query_string_params = {})
        return path if query_string_params.blank?
        "#{path}?#{query_string_params.to_query}"
      end

      def avatar_for(user, additional_css_class = '')
        if user.blank?
          return content_tag(
            :span,
            t('workarea.admin.application_helper.not_applicable'),
            class: "avatar #{additional_css_class}"
          )
        end

        image_tag(
          user.avatar_image_url,
          class: "avatar #{additional_css_class}",
          width: 40,
          alt: t('workarea.admin.layout.avatar_title', name: user.name)
        )
      end

      def relative_weekday(date)
        if date == Date.current
          t('workarea.admin.application_helper.today')
        elsif (Date.current - date) == 1
          t('workarea.admin.application_helper.yesterday')
        else
          date.strftime('%A')
        end
      end

      def toggle_button_for(object_name, condition, options = {}, &block)
        block = capture(&block) if block_given?

        # TODO: v4 reduce size (lolwat)
        render(
          'workarea/admin/shared/toggle_button',
          input_name: object_name,
          condition: condition,
          label_true: options[:label_true].presence || t('workarea.admin.true'),
          label_false: options[:label_false].presence || t('workarea.admin.false'),
          title_true: options[:title_true].presence || t('workarea.admin.true'),
          title_false: options[:title_false].presence || t('workarea.admin.false'),
          block: block,
          data: options[:data],
          disabled: options[:disabled],
          dom_id: object_name.systemize.chomp('_') + (options[:id].present? ? "_#{options[:id]}" : '')
        )
      end

      def flash_messages
        flash.keys.inject('') do |memo, name|
          msg = flash[name]

          if msg.is_a?(Enumerable)
            msg.each do |message|
              if message.is_a?(String)
                memo << render_message(name, message)
              end
            end
          elsif msg.is_a?(String)
            memo << render_message(name, msg)
          end

          flash.delete(name)
          memo
        end.html_safe
      end

      def render_message(type, message = nil, &block)
        message = capture(&block) if block_given?
        render('workarea/admin/shared/message', type: type.systemize, message: message)
      end

      def pagination_path_for(page: 1)
        new_query_string_params = request.query_parameters.merge(page: page)
        "#{request.path}?#{new_query_string_params.to_query}"
      end

      def s3?
        Configuration::S3.configured?
      end

      def workarea_release_notes_url(version)
        version_path = "workarea-#{version.gsub('.', '-')}.html"
        "https://developer.workarea.com/release-notes/#{version_path}"
      end

      def duration_in_words(duration)
        parts = duration.parts
        return t('workarea.duration.seconds', count: 0) if parts.empty?

        parts
          .sort_by { |unit,  _ | ActiveSupport::Duration::PARTS.index(unit) }
          .map     { |unit, val| t("workarea.duration.#{unit}", count: val) }
          .to_sentence
      end

      def navigation_redirects_enabled?
        !Rails.application.config.consider_all_requests_local
      end
    end
  end
end
