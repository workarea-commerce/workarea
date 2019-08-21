require 'active_support/testing/time_helpers'

module Workarea
  class CustomersSeeds
    include ActiveSupport::Testing::TimeHelpers

    def perform
      puts 'Adding customers...'

      20.times do |i|
        travel_to rand(12).weeks.ago

        User.create!(
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name
        )

        travel_back
      end
    end
  end
end
