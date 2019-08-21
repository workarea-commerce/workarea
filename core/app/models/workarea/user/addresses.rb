module Workarea
  class User
    module Addresses
      extend ActiveSupport::Concern

      included do
        embeds_many :addresses,
                    class_name: 'Workarea::User::SavedAddress',
                    as: :addressable,
                    cascade_callbacks: true
      end

      def default_billing_address
        addresses
          .select { |a| a.last_billed_at }
          .sort { |a, b| a.last_billed_at <=> b.last_billed_at }
          .last || last_modified_address
      end

      def default_shipping_address
        addresses
          .select { |a| a.last_shipped_at }
          .sort { |a, b| a.last_shipped_at <=> b.last_shipped_at }
          .last || last_modified_address
      end

      def auto_save_billing_address(params)
        address = find_existing_address_or_new(params)
        address.last_billed_at = Time.current
        address.save
      end

      def auto_save_shipping_address(params)
        address = find_existing_address_or_new(params)
        address.last_shipped_at = Time.current
        address.save
      end

      private

      def last_modified_address
        addresses.sort { |a, b| a.updated_at <=> b.updated_at }.last
      end

      def find_existing_address_or_new(params)
        new = SavedAddress.new(params)
        addresses.detect { |a| a.address_eql?(new) } || addresses.new(params)
      end
    end
  end
end
