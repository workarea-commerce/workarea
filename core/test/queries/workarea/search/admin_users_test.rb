require 'test_helper'

module Workarea
  module Search
    class AdminUsersTest < IntegrationTest
      def test_sort
        one = create_user(email: 'foo@workarea.com')
        two = create_user(email: 'bar@workarea.com')

        Metrics::User.save_order(email: one.email, revenue: 50)
        Metrics::User.save_order(email: two.email, revenue: 5)
        Search::Admin::User.new(one).save
        Search::Admin::User.new(two).save

        search = AdminUsers.new(sort: Sort.most_spent.to_s)
        assert_equal([one, two], search.results)
      end
    end
  end
end
