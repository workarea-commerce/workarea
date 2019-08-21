module Workarea
  class AdminsSeeds
    def perform
      puts 'Adding admin users...'

      User.create!(
        email: 'user@workarea.com',
        password: password,
        first_name: 'Ben',
        last_name: 'Crouse',
        super_admin: true,
        releases_access: true,
        store_access: true,
        catalog_access: true,
        orders_access: true,
        people_access: true,
        marketing_access: true,
        help_admin: true,
        permissions_manager: true,
        settings_access: true,
        search_access: true,
        can_publish_now: true
      )

      User.create!(
        email: 'qa@workarea.com',
        password: password,
        first_name: 'Bob',
        last_name: 'Clams',
        admin: true,
        releases_access: true,
        store_access: true,
        catalog_access: true,
        orders_access: true,
        people_access: true,
        marketing_access: true,
        help_admin: true,
        permissions_manager: true,
        settings_access: true,
        search_access: true,
        can_publish_now: false
      )
    end

    def password
      if Rails.env.development?
        'w0rkArea!'
      else
        "#{SecureRandom.hex(10)}_aA1"
      end
    end
  end
end
