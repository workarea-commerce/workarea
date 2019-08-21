module Workarea
  module I18n
    module DefaultUrlOptions
      def default_url_options(options = {})
        locale = ::I18n.locale != ::I18n.default_locale ? ::I18n.locale : nil
        { locale: locale }.merge(options)
      end
    end

    class << self
      # Returns an array representing the locales configured by the host Rails
      # application. This is distinctly different from ::I18n.available_locales
      # so that we can ignore locales that gems add. Usually the host app does
      # not intend to use locales added by gems.
      #
      # @return [Array<Symbol>]
      #
      def configured_locales
        Rails.application.config.i18n.available_locales ||
          [Rails.application.config.i18n.default_locale]
      end

      # Execute the block passed for each configured available locale. It uses
      # the available locales from the Rails config over the I18n module
      # because gems may add to the I18n.available_locales which the app doesn't
      # intend to use.
      #
      def for_each_locale
        configured_locales.each do |locale|
          ::I18n.with_locale(locale) do
            yield(locale)
          end
        end
      end

      # Returns the value for the constraint of the :locale param in routing,
      # with respect to the current env and currently configured locales.
      #
      # When testing, we don't want any real constraints so we can freely
      # configure and test that i18n features work correctly.
      #
      # @return [Hash]
      #
      def routes_constraint
        if Rails.env.test?
          { locale: /\w{2}/ }
        else
          { locale: Regexp.new(available_locales.join('|')) }
        end
      end

      # Delegate all other methods to the global I18n.
      #
      def method_missing(method, *args, &block)
        if ::I18n.respond_to?(method)
          self.class.send(:define_method, method) do |*arguments, &blok|
            ::I18n.send(method, *arguments, &blok)
          end

          send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        super || ::I18n.respond_to?(method_name)
      end
    end
  end
end
