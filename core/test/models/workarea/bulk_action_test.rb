require 'test_helper'

module Workarea
  class BulkActionTest < Workarea::IntegrationTest
    class FooAction < BulkAction
      attr_reader :acted_on
      field :settings, type: Hash, default: {}

      def act_on!(model)
        @acted_on ||= []
        @acted_on << model
      end
    end

    def test_perform_from_search
      pages = [create_page, create_page]
      query = Search::AdminPages.new(q: '*')
      action = FooAction.create!(query_id: query.to_global_id)

      action.perform!
      assert_equal(2, action.acted_on.size)
      assert_includes(action.acted_on, pages.first)
      assert_includes(action.acted_on, pages.second)

      action = FooAction.create!(
        query_id: query.to_global_id,
        exclude_ids: [pages.first.to_global_id.to_param]
      )

      action.perform!
      assert_equal(pages.last(1), action.acted_on)
    end

    def test_perform_from_selection
      pages = [create_page, create_page]
      action = FooAction.create!(ids: [pages.first.to_global_id.to_param])

      action.perform!
      assert_equal(pages.take(1), action.acted_on)
    end

    def test_reset_to_default!
      query = Search::AdminSearch.new(q: '*')
      action = FooAction.create!(
        query_id: query.to_global_id,
        exclude_ids: ['1234'],
        settings: { 'foo' => 'bar' }
      )

      action.reset_to_default!

      assert_equal(['1234'], action.exclude_ids)
      assert_equal({}, action.settings)
    end

    def test_convert_query_to_ids
      create_product
      two = create_product(name: 'Foo A')
      three = create_product(name: 'Foo B')
      four = create_product(name: 'Foo C')

      query = Search::AdminProducts.new(q: 'foo', sort: 'name_asc')
      edit = FooAction.new(
        query_id: query.to_global_id,
        exclude_ids: [three.to_global_id.to_param]
      )

      edit.convert_query_to_ids

      assert_equal(2, edit.ids.size)
      assert_includes(edit.ids, two.to_global_id.to_param)
      assert_includes(edit.ids, four.to_global_id.to_param)
    end

    def test_blank_ids
      query = Search::AdminSearch.new(q: '*')
      action = FooAction.new(query_id: query.to_global_id, ids: [""])

      refute_empty(action.ids)
      assert(action.valid?, action.errors.full_messages.to_sentence)
      assert_empty(action.ids)
    end
  end
end
