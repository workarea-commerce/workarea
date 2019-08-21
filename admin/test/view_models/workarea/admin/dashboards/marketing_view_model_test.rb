require 'test_helper'

module Workarea
  module Admin
    module Dashboards
      class MarketingViewModelTest < TestCase
        def test_email_signups
          create_email_signup(created_at: Time.zone.local(2018, 12, 31))
          create_email_signup(created_at: Time.zone.local(2019, 1, 3))
          create_email_signup(created_at: Time.zone.local(2019, 1, 9))
          create_email_signup(created_at: Time.zone.local(2019, 1, 10))
          travel_to Time.zone.local(2019, 1, 10)

          view_model = MarketingViewModel.new
          assert_equal(2, view_model.email_signups)
          assert_equal(100, view_model.email_signups_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 1, Date.new(2019, 1, 9) => 1 },
            view_model.email_signups_graph_data
          )
        end
      end
    end
  end
end
