module Workarea
  class User
    module SystemUsers
      extend ActiveSupport::Concern

      class_methods do
        def console
          find_system_user!('Console', 'User')
        end

        def find_system_user!(first_name, last_name)
          mailbox = "#{first_name}-#{last_name}".systemize
          email = "#{mailbox}@system.workarea.com"

          find_by_email(email) || create!(
            email: email,
            password: "#{SecureRandom.hex}_aA1", # extra chars to appease requirements
            first_name: first_name,
            last_name: last_name,
            super_admin: true
          )
        end
      end

      def system?
        email.ends_with?('system.workarea.com')
      end
    end
  end
end
