module Workarea
  module Search
    class UserText
      def initialize(user)
        @user = user
      end

      def text
        [
          'user people',
          @user.email,
          @user.first_name,
          @user.last_name,
          @user.tags,
          addresses_text,
          type_text
        ].flatten.join(' ')
      end

      def addresses_text
        (@user.addresses || []).map do |address|
          [
            address.street,
            address.street_2,
            address.city,
            address.region,
            address.region_name,
            address.postal_code,
            address.country.name,
            address.country.alpha2,
            address.phone_number
          ].join(' ')
        end
      end

      def type_text
        if @user.admin?
          'admin administrator'
        else
          'customer'
        end
      end
    end
  end
end
