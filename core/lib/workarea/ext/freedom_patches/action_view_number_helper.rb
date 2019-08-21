module ActionView
  module Helpers
    module NumberHelper
      def number_to_currency_with_workarea(number, options = {})
        if options[:unit].present? || options[:locale].present?
          return number_to_currency_without_workarea(number, options)
        end

        options = options.deep_dup
        options[:unit] = if number.is_a?(Money)
                           number.currency.symbol
                         else
                           Money.default_currency.symbol
                         end

        number_to_currency_without_workarea(number, options)
      end

      alias_method :number_to_currency_without_workarea, :number_to_currency
      alias_method :number_to_currency, :number_to_currency_with_workarea
    end
  end
end
