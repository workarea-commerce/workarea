module Workarea
  module Admin::ReleasesHelper
    def release_options
      @release_options ||= ([current_release] + Release.upcoming.to_a)
                                .reject(&:blank?)
                                .uniq(&:id)
                                .map { |r| Admin::ReleaseViewModel.wrap(r) }
    end

    def release_select_attributes
      css_class = ''
      css_class << 'release-select--active' if current_release.present?
      css_class << ' release-select--emphasize' if current_release_session.remind?

      { class: css_class, data: { release_reminder: '' } }
    end

    def publishing_options_for_select(selected = current_release.try(:id))
      results = release_options.map do |release|
        [
          sanitize(
            t(
              'workarea.admin.releases.select.publish_with',
              release: release.name
            )
          ),
          release.id
        ]
      end

      now_option = [t('workarea.admin.releases.select.publishing_now'), :now]
      now_option << { data: { disable_publish_now: '' } } unless allow_publishing?
      results.unshift(now_option)

      options_for_select(results, selected)
    end

    def release_options_for_select(selected = current_release.try(:id))
      results = release_options.map { |r| [r.name, r.id] }
      results.unshift([t('workarea.admin.releases.select.live_site'), nil])
      options_for_select(results, selected)
    end

    #
    # Change helpers
    #
    #

    def render_changeset_field(changeset, field)
      custom_partial = "workarea/admin/changesets/fields/_#{field}"

      partial = if lookup_context.find_all(custom_partial).present?
                  "workarea/admin/changesets/fields/#{field}"
                else
                  'workarea/admin/changesets/fields/generic'
                end

      options = {
        release: changeset.release,
        model: changeset.releasable,
        field: field,
        old_value: changeset.old_value_for(field),
        new_value: changeset.new_value_for(field)
      }

      render(partial, options)
    end

    def change_display_value(value)
      case value
      when FalseClass then t('workarea.admin.false')
      when TrueClass then t('workarea.admin.true')
      when DateTime, Time then value.to_s(:long)
      when Array then value.map { |v| change_display_value(v) }.join(', ')
      when Money then number_to_currency(value)
      else
        if UrlValidator.valid_url?(value)
          link_to truncate(value, length: 35), value, target: '_blank', rel: 'noopener'
        else
        value.to_s
        end
      end
    end

    #
    # Custom change field helpers
    #
    #

    def product_links(ids)
      model_links(Catalog::Product, ids)
    end

    def category_links(ids)
      model_links(Catalog::Category, ids)
    end

    def discount_links(ids)
      model_links(Pricing::Discount, ids)
    end

    def segment_links(ids)
      model_links(Segment, ids)
    end

    def for_each_content_block_from_changeset(content, change_hash)
      change_hash.each do |id, changes|
        block = content.blocks.detect { |b| b.id.to_s == id.to_s }
        yield(block, changes) if block.present?
      end
    end

    def content_block_data_changes_from(old_data, new_data)
      return {} if new_data.blank?
      locale = I18n.locale.to_s

      old_data = old_data[locale] if old_data.keys.include?(locale)
      new_data = new_data[locale] if new_data.keys.include?(locale)

      new_data.select do |key, value|
        old_data[key] != new_data[key]
      end
    end

    def render_content_block_changes(old_data, new_data, prefixes = [])
      new_data = content_block_data_changes_from(old_data, new_data)

      new_data.map do |field, value|
        if !value.present?
          nil
        elsif value.is_a?(Hash)
          render_content_block_changes(
            old_data[field],
            new_data[field],
            prefixes + [field],
            &block
          )
        else
          custom_partial = "workarea/admin/changesets/fields/data/_#{field}"

          partial = if lookup_context.find_all(custom_partial).present?
                      "workarea/admin/changesets/fields/data/#{field}"
                    else
                      'workarea/admin/changesets/fields/data/generic'
                    end

          options = {
            field: (prefixes + [field]).join(' '),
            old_value: old_data[field],
            new_value: new_data[field]
          }

          render(partial, options)
        end
      end.compact.join.html_safe
    end

    #
    # Calendar classes
    #
    #

    def month_and_year_from_date(date)
      "#{Date::MONTHNAMES[date.month]} #{date.year}"
    end

    def month_name_needed?(day, days)
      return true if day == days.first.first
      return true if day.split('-').last == '01'
    end

    def calendar_day_number(day)
      Date.parse(day).day
    end

    def calendar_day_classes(day)
      date = Date.parse(day)
      today = Date.current

      classes = ['calendar__day']
      classes << 'calendar__day--odd-month'     if date.month.odd?
      classes << 'calendar__day--today'         if date == today
      classes << 'calendar__day--start-of-week' if date == date.beginning_of_week(start_day = :sunday)
      classes << 'calendar__day--end-of-week'   if date == date.end_of_week(start_day = :sunday)

      classes
    end

    private

    def model_links(klass, ids)
      klass.any_in(id: ids).map do |model|
        link_to model.name,
          polymorphic_path(model),
          data: { summary_tooltip: polymorphic_path(model) }
      end
    end

    def release_text_color(hex_color)
      # algorithm based on https://stackoverflow.com/a/3943023
      red, green, blue = hex_color.scan(/../).map { |c| c.to_i(16) }
      (red * 0.299 + green * 0.587 + blue * 0.114 > 186) ? "000000" : "ffffff"
    end
  end
end
