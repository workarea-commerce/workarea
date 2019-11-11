require 'test_helper'

module Mongoid
  class EmbeddedChildrenTest < Workarea::TestCase
    class Parent
      include Mongoid::Document
      embeds_one :child, class_name: 'Mongoid::EmbeddedChildrenTest::Child'
      embeds_many :children, class_name: 'Mongoid::EmbeddedChildrenTest::Child'
    end

    class Child
      include Mongoid::Document
      field :name, type: String
      embeds_one :grandchild, class_name: 'Mongoid::EmbeddedChildrenTest::Grandchild'
      embeds_many :grandchildren, class_name: 'Mongoid::EmbeddedChildrenTest::Grandchild'
    end

    class Grandchild
      include Mongoid::Document
      field :name, type: String
    end

    def test_embedded_children
      model = Parent.create!(
        child: { name: '1', grandchild: { name: '2' } },
        children: [{ name: '3' }, { name: '4', grandchildren: [{ name: '5' }] }]
      )

      assert_equal(%w(1 2 3 4 5), model.embedded_children.map(&:name))
    end
  end
end
