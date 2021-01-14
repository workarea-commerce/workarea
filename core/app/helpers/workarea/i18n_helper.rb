module Workarea
  module I18nHelper
    def locale_options
      I18n.configured_locales.reduce([]) do |memo, locale|
        I18n.with_locale(locale) { memo << [t(:name), locale] }
      end
    end

    def switch_locale_fields
      result = ''

      params
        .except(:utf8, :controller, :action, :locale)
        .each_pair { |key, value| result << hidden_field_tag(key, value, id: nil) }

      result.html_safe
    end
  end
end
