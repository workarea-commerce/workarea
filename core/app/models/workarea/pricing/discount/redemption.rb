module Workarea
  module Pricing
    class Discount
      # Represents an instance of redemption for a {Discount}.
      # Used for calculating single use discounts.
      #
      class Redemption
        include ApplicationDocument

        # @!attribute email
        #   @return [String] the email that received the discount
        #
        field :email, type: String

        # @!attribute discount
        #   @return [Discount] the discount
        #
        belongs_to :discount,
          class_name: 'Workarea::Pricing::Discount'

        index({ discount_id: 1, email: 1 })

        before_validation :downcase_email

        private

        def downcase_email
          self.email = email.downcase if email.present?
        end
      end
    end
  end
end
