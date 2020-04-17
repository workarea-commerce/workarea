module I18n
  module JS
    class FallbackLocales
      # i18n-js uses just the second part of this check out-of-the-box. This
      # causes the I18n fallbacks to get autoloaded without the developer
      # knowing.
      #
      # This surfaces in tests. System or integration tests will do this check
      # for compiling assets, then I18n fallbacks get autoloaded. So this shows
      # as some tests not having fallbacks if they run before one of those tests
      # or magically having fallbacks if they run after one of those types of
      # tests.
      #
      # Adding the `respond_to?` check doesn't cause autoload, but will return
      # `true` if fallbacks are enabled. Retain the original check because we
      # want the current I18n::JS backend to be checked, once fallbacks are
      # `require`d `I18n.respond_to?(:fallbacks)` will always return `true`.
      #
      # See also: https://github.com/fnando/i18n-js/blob/master/lib/i18n/js/fallback_locales.rb#L49-L58
      #
      def using_i18n_fallbacks_module?
        I18n.respond_to?(:fallbacks) &&
          I18n::JS.backend.class.included_modules.include?(I18n::Backend::Fallbacks)
      end
    end
  end
end
