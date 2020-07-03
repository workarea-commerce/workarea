import I18n from "i18n"
import translations from "i18n/filtered.js.erb"

I18n.fallbacks = true
I18n.translations = translations

const locale = document.querySelector('meta[property="locale"]')
                       .getAttribute('content')

if (locale) {
  I18n.locale = locale
}

export default I18n
