require 'test_helper'

module Workarea
  module Catalog
    class CustomizationsTest < TestCase
      class FooCustomizations < Workarea::Catalog::Customizations
        customized_fields :foo, :bar, :a_test, :title_graphic, :category_id, :screaming_snake_id
      end

      def test_handles_attributes_with_a_space_in_them
        customizations = FooCustomizations.new(
          '1234',
          'A Test' => 'Hello, World',
          'titleGraphic' => 'gritty.jpg',
          'category_id' => 'CAT',
          'SCREAMING_SNAKE_ID' => '🐍'
        )

        assert_equal('Hello, World', customizations.a_test)
        assert_equal('gritty.jpg', customizations.title_graphic)
        assert_equal('CAT', customizations.category_id)
        assert_equal('🐍', customizations.screaming_snake_id)
      end

      def test_to_h
        customizations = FooCustomizations.new('1234', foo: 'test', bar: '')
        assert_equal({ foo: 'test' }, customizations.to_h.symbolize_keys)
      end
    end
  end
end
