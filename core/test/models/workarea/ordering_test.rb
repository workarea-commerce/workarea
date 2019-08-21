require 'test_helper'

module Workarea
  class OrderingTest < TestCase
    class FooParent
      include ApplicationDocument

      embeds_many :foos, class_name: "Workarea::OrderingTest::FooChild"
      embeds_many :foo_fighters, class_name: "Workarea::OrderingTest::FooChild"
    end

    class FooChild
      include ApplicationDocument
      include Ordering

      embedded_in :bar,
        class_name: "Workarea::OrderingTest::FooParent",
        inverse_of: :foos

      embedded_in :bar,
        class_name: "Workarea::OrderingTest::FooParent",
        inverse_of: :foo_fighters
    end

    def test_ordering_embedded_relations
      doc = FooParent.create(
        foos: [
          FooChild.new,
          FooChild.new
        ],
        foo_fighters: [
          FooChild.new,
          FooChild.new
        ],
      )

      assert_equal([0, 1], doc.foos.map(&:position))
      assert_equal([0, 1], doc.foo_fighters.map(&:position))
    end
  end
end
