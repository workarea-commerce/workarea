require 'test_helper'

module Workarea
  module Admin
    class ImportsHelperTest < ViewTest
      class Foo
        include ApplicationDocument
        field :foo, type: String
        embeds_many :bars
        validates :foo, presence: true, inclusion: { in: %(baz qux) }
      end

      class Bar
        include ApplicationDocument
        field :bar, type: String
        embedded_in :foo
        validates :bar, uniqueness: true
      end

      def test_rendering_validations
        results = render_validations_for(Foo)
        assert_includes(results, 'presence')
        assert_includes(results, 'foo')
        assert_includes(results, 'baz')
        assert_includes(results, 'qux')
        assert_includes(results, 'bar')
        assert_includes(results, 'uniqueness')
      end
    end
  end
end
