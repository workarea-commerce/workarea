require 'test_helper'

module Workarea
  class IndexAdminSearchTest < TestCase
    def test_should_enqueue
      refute(IndexAdminSearch.should_enqueue?(create_order))
      assert(IndexAdminSearch.should_enqueue?(create_placed_order))
    end

    def test_enqueuing_embedded_documents
      content = create_content

      Sidekiq::Testing.fake!
      IndexAdminSearch.drain
      Sidekiq::Callbacks.async(IndexAdminSearch)
      Sidekiq::Callbacks.enable(IndexAdminSearch)

      assert_difference 'IndexAdminSearch.jobs.size', 1 do
        content.blocks.create!(type: :html)
      end

      args = IndexAdminSearch.jobs.first['args']
      assert_equal(Content.name, args.first)
      assert_equal(content.id.to_s, args.second)

    ensure
      IndexAdminSearch.drain
      Sidekiq::Testing.inline!
    end
  end
end
