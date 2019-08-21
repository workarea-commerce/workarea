module Workarea
  module Pricing
    class Discount
      # This class represents one instance of a promo code generated
      # by a {CodeList}.
      #
      class GeneratedPromoCode
        include ApplicationDocument

        # @!attribute code
        #   @return [String] the promo code
        #
        field :code, type: String

        # @!attribute expires_at
        #   @return [Time, nil] when the code expires
        #
        field :expires_at, type: Time

        # @!attribute used_at
        #   @return [Time, nil] when the code was used (if at all)
        #
        field :used_at, type: Time

        # @!attribute code_list
        #   @return [Enumerable<CodeList>] the code list that generated
        #     this code.
        #
        belongs_to :code_list,
          class_name: 'Workarea::Pricing::Discount::CodeList',
          index: true

        # Get unused codes
        #
        # @scope class
        # @return [Mongoid::Criteria]
        #
        scope :unused, -> { where(used_at: nil) }

        # Get codes that have not expired
        #
        # @scope class
        # @return [Mongoid::Criteria]
        #
        scope :not_expired, -> { any_of({ expires_at: nil },
                                        { :expires_at.gt => Time.current }) }

        index({ code: 1 }, { unique: true })

        before_validation :downcase_code

        # Generate a new, unique code
        #
        # @param optional [String] prefix
        # @return [String]
        #
        def self.generate_code(prefix = nil)
          "#{prefix}#{SecureRandom.hex(3)}".downcase
        end

        # Find an instance based on its code. Case-insensitive.
        #
        # @param [String] code
        # @return [GeneratedPromoCode, nil]
        #
        def self.find_by_code(code)
          find_by(code: code.strip.downcase) rescue nil
        end

        # Whether the code passed is unused and not expired (i.e. valid
        # for customer use).
        #
        # @param [String] code
        # @return [Boolean]
        #
        def self.valid_code?(code)
          unused.not_expired.where(code: code.strip.downcase).exists?
        end

        # Mark this code as being used, so it can't be used again.
        #
        # @return [Boolean]
        #
        def used!
          update_attribute(:used_at, Time.current)
        end

        private

        def downcase_code
          self.code = code.downcase if code.present?
        end
      end
    end
  end
end
