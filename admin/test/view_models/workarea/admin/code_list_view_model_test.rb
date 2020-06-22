require 'test_helper'

module Workarea
  module Admin
    class CodeListViewModelTest < TestCase
      setup :code_list

      def code_list
        @code_list ||= create_code_list(
          count: 4,
          prefix: 'test',
          expires_at: 1.day.from_now
        ).tap(&:generate_promo_codes!)
      end

      def test_used_count
        view_model = CodeListViewModel.wrap(code_list)
        assert_equal(0, view_model.used_count)

        code_list.promo_codes.sample.update(used_at: Time.now)

        view_model = CodeListViewModel.wrap(code_list)
        assert_equal(1, view_model.used_count)

        code_list.promo_codes.create!(code: "#{code_list.prefix}123")

        view_model = CodeListViewModel.wrap(code_list)
        assert_equal(1, view_model.used_count)
      end

      def test_last_used_at
        view_model = CodeListViewModel.wrap(code_list)
        assert_nil(view_model.last_used_at)

        yesterday = 1.day.ago
        code_list.promo_codes.unused.sample.update(used_at: yesterday)

        view_model = CodeListViewModel.wrap(code_list)
        assert_equal(yesterday.to_i, view_model.last_used_at.to_i)

        code_list.promo_codes.unused.sample.used!

        view_model = CodeListViewModel.wrap(code_list)
        refute_equal(yesterday.to_i, view_model.last_used_at.to_i)
      end
    end
  end
end
