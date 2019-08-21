module Workarea
  module Pricing
    class Discount
      module Conditions
        module PromoCodes
          extend ActiveSupport::Concern

          included do
            # @!attribute promo_codes
            #   @return [Array] an array of strings of eligible promo codes
            #
            field :promo_codes, type: Array, default: []
            list_field :promo_codes

            # @!attribute generated_codes_id
            #   @return [String, nil] the id for the {Workarea::Pricing::Discount::CodeList}.
            #
            field :generated_codes_id, type: String

            add_qualifier :promo_codes_qualify?
            index({ promo_codes: 1 })
          end

          # @private
          def valid?(*)
            promo_codes.map!(&:downcase)
            super
          end

          # The generated codes this discount is configured to check as part
          # of its conditions.
          #
          # @return [nil,  CodeList]
          #
          def generated_codes
            @generated_codes ||= CodeList.find(generated_codes_id) rescue nil
          end

          # Whether this discount has any promo code conditions.
          #
          # @return [Boolean]
          #
          def promo_code?
            promo_codes.present? || generated_codes_id.present?
          end

          # Whether this discount passes its promo code conditions.
          #
          # @param [Pricing::Discount::Order] order
          # @return [Boolean]
          #
          def promo_codes_qualify?(order)
            return true unless promo_code?

            codes = order.promo_codes.reject(&:blank?).map(&:downcase)
            return false if codes.empty?

            array_qualifies?(codes) || generated_qualifies?(codes)
          end

          private

          def array_qualifies?(test_codes)
            valid_codes = promo_codes.map(&:downcase)
            return false unless valid_codes.present?

            (test_codes & valid_codes).any?
          end

          def generated_qualifies?(test_codes)
            return false if generated_codes_id.blank? || generated_codes.blank?
            generated_codes.valid_codes?(test_codes)
          end
        end
      end
    end
  end
end
