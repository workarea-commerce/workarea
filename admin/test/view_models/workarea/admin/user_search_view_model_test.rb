require 'test_helper'

module Workarea
  module Admin
    class UserSearchViewModelTest < TestCase
      def test_uses_the_configured_sort_match_if_it_exists
        sort = UserSearchViewModel.new(
          Search::AdminUsers.new,
          sort: Sort.most_spent.to_s
        ).sort

        assert_equal(Sort.most_spent, sort)
      end
    end
  end
end
