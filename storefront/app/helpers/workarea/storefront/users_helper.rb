module Workarea
  module Storefront
    module UsersHelper
      def minimum_password_length
        PasswordValidator::MIN_LENGTHS[Workarea.config.password_strength]
      end
    end
  end
end
