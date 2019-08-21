module Workarea
  module I18nHelper
    def locale_options
      I18n.configured_locales.reduce([]) do |memo, locale|
        memo << [I18n.t(:name, locale: locale), locale]
      end
    end

    def switch_locale_fields
      result = ''

      params
        .except(:utf8, :controller, :action)
        .each_pair { |key, value| result << hidden_field_tag(key, value, id: nil) }

      result.html_safe
    end
  end
end
