module Workarea
  module Pricing
    class Discount
      # This class determines whether an item can qualify for a
      # {Pricing::Discount::ProductAttribute} discount.
      #
      class ProductAttribute::ItemQualifier
        attr_reader :discount, :item
        delegate :attribute_name, :attribute_value, to: :discount

        def initialize(discount, item)
          @discount = discount
          @item = item
        end

        # Whether the item qualifies, as defined by an optionaize comparision
        # of keys and value or any element of the array if the item has an
        # array.
        #
        # @return [Boolean]
        #
        def qualifies?
          !!details.detect do |key, value|
            next unless key.to_s.optionize == attribute_name.optionize

            if value.respond_to?(:any?)
              value.any? { |v| v.to_s.optionize == attribute_value.optionize }
            else
              value.to_s.optionize == attribute_value.optionize
            end
          end
        end

        private

        # Ugliness ensues to deal with not having the product model here, but
        # wanting to respect Mongoid localization.
        #
        def details
          return {} unless item.product_attributes.present?
          all_details = item.product_attributes['details']

          if all_details.key?(I18n.locale.to_s)
            all_details[I18n.locale.to_s]
          else
            all_details
          end
        end
      end
    end
  end
end
