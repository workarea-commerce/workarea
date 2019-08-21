module Workarea
  module Storefront
    module LocalesHelper
      def alternate_locales_tags
        return if I18n.configured_locales.one?

        alternate_locale_urls.reduce('') do |memo, (locale, url)|
          memo << tag(:link, href: url, rel: 'alternate', hreflang: locale)
        end.html_safe
      end

      def alternate_locale_urls
        I18n.configured_locales.reduce({}) do |memo, locale|
          next memo if locale == I18n.locale || locale.blank?

          memo[locale] = if locale == I18n.default_locale
                           url_for(locale: nil)
                         else
                           url_for(locale: locale)
                         end

          memo
        end
      end
    end
  end
end
