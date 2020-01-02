module Workarea
  module Pricing
    class Discount
      class CodeList
        include ApplicationDocument

        # @!attribute name
        #   @return [String] name
        #
        field :name, type: String

        # @!attribute prefix
        #   @return [String] string to prefix the generated codes
        #
        field :prefix, type: String

        # @!attribute expires_at
        #   @return [Array] when these codes expire
        #
        field :expires_at, type: Time

        # @!attribute count
        #   @return [Array] the number of codes to generate
        #
        field :count, type: Integer

        # @!attribute generation_completed_at
        #   @return [Array] the number of codes to generate
        #
        field :generation_completed_at, type: Time

        validates :name, presence: true
        validates :count, presence: true,
          numericality: {
            greater_than_or_equal_to: 1,
            only_integer: true
          }

        # @!attribute promo_codes
        #   @return [Enumerable<GeneratedPromoCode>] the list of promo codes that have been generated
        #
        has_many :promo_codes,
          class_name: 'Workarea::Pricing::Discount::GeneratedPromoCode',
          dependent: :delete_all

        after_update :update_codes

        # This method creates a set of promo codes for this discount.
        #
        # @return [Integer] the number of generated codes
        #
        def generate_promo_codes!
          count.times { generate_code }
          update_attributes!(generation_completed_at: Time.current)
        end

        # Whether the list finished generating its codes
        #
        # @return [Boolean]
        #
        def generation_complete?
          generation_completed_at.present?
        end

        # Whether any of the strings passed is a qualifying code
        # for this discount. Used when checking discount conditions.
        #
        # @param [Array<String>]
        # @return [Boolean]
        #
        def valid_codes?(test_codes)
          promo_codes
            .not_expired
            .unused
            .where(:code.in => test_codes.map(&:to_s).map(&:downcase))
            .exists?
        end

        private

        def update_codes
          promo_codes.update_all(expires_at: expires_at) if expires_at_changed?
        end

        def generate_code
          result = nil

          until result.present?
            code = GeneratedPromoCode.generate_code(prefix)
            begin
              result = promo_codes.create!(code: code, expires_at: expires_at)
            rescue Mongo::Error::OperationFailure
              # unique index violated, let it try again
            end
          end
        end
      end
    end
  end
end
