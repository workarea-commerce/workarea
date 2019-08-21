require 'test_helper'

module Workarea
  class Content
    class BlockTest < TestCase
      setup :set_content

      def set_content
        @content = create_content
      end

      def test_valid_typecasts_boolean_values
        block = @content.blocks.create!(
          area: 'body',
          type: :divider,
          data: { 'show_line' => 'true' }
        )
        assert(block.data['show_line'])
        block.update_attributes(data: { 'show_line' => 'false' })
        refute(block.data['show_line'])

        # NOTE: This is to test the type consistency of `data.show_line`
        #       when validations/callbacks are executed on the model.
        block.position = 3
        block.save!

        refute(block.data['show_line'])
      end

      def test_valid_sets_block_type_data_as_preset
        block = @content.blocks.build(type: :html)
        block.valid?

        assert(block.data[:html].present?)
      end

      def test_valid_typecasts_the_values_in_the_data_block
        block = @content.blocks.create!(
          area: 'body',
          type: :html,
          data: { 'html' => 1 }
        )

        assert_equal('1', block.data['html'])

        block.update_attributes(data: { 'html' => 2 })
        assert_equal('2', block.data['html'])
      end

      def test_valid_is_not_valid_if_type_is_blank
        block = @content.blocks.build(area: 'body')
        refute(block.valid?)
      end

      def test_valid_requires_any_fields_which_are_required
        block = @content.blocks.build(type: :hero, data: { foo: 'bar' })
        refute(block.valid?)
        assert(block.errors[:asset].present?)
      end

      def test_default_scope_is_ordered_by_position
        block_3 = @content.blocks.create!(area: 'body', type: :html, position: 3)
        block_1 = @content.blocks.create!(area: 'body', type: :html, position: 1)
        block_2 = @content.blocks.create!(area: 'body', type: :html, position: 2)

        assert_equal([block_1, block_2, block_3], @content.blocks.all)
      end

      def test_data_uses_a_hash_with_indifferent_access
        block = @content.blocks.create!(area: 'body', type: :html)
        assert(block.data.instance_of?(HashWithIndifferentAccess))

        block.data[:one] = 1
        assert_equal(1, block.data[:one])
        assert_equal(1, block.data['one'])

        block.save!
        block.reload

        assert_equal(1, block.data[:one])
        assert_equal(1, block.data['one'])
      end

      def test_position_sets_the_default_as_they_grow
        a = @content.blocks.create!(area: 'body', type: :html, data: { id: 'a' })
        b = @content.blocks.create!(area: 'body', type: :html, data: { id: 'b' })
        c = @content.blocks.create!(area: 'body', type: :html, data: { id: 'c' })
        @content.reload

        assert_equal(0, a.position)
        assert_equal(1, b.position)
        assert_equal(2, c.position)

        @content.blocks.destroy_all
        a = @content.blocks.build(area: 'body', type: :html, data: { id: 'a' })
        b = @content.blocks.build(area: 'body', type: :html, data: { id: 'b' })
        c = @content.blocks.build(area: 'body', type: :html, data: { id: 'c' })
        @content.save!
        @content.reload

        assert_equal(0, a.position)
        assert_equal(1, b.position)
        assert_equal(2, c.position)
      end

      def test_position_can_insert_onto_the_top_of_the_list
        a = @content.blocks.create!(area: 'body', type: :html)
        b = @content.blocks.create!(area: 'body', type: :html)
        c = @content.blocks.create!(area: 'body', type: :html)
        d = @content.blocks.create!(area: 'body', type: :html, position: 0)
        @content.reload

        assert_equal(0, d.position)
        assert_equal(1, a.position)
        assert_equal(2, b.position)
        assert_equal(3, c.position)
      end

      def test_position_can_insert_into_the_middle_of_the_list
        a = @content.blocks.create!(area: 'body', type: :html)
        b = @content.blocks.create!(area: 'body', type: :html)
        c = @content.blocks.create!(area: 'body', type: :html)
        d = @content.blocks.create!(area: 'body', type: :html, position: 1)
        @content.reload

        assert_equal(0, a.position)
        assert_equal(1, d.position)
        assert_equal(2, b.position)
        assert_equal(3, c.position)
      end

      def test_position_can_insert_onto_the_end_of_the_list
        a = @content.blocks.create!(area: 'body', type: :html)
        b = @content.blocks.create!(area: 'body', type: :html)
        c = @content.blocks.create!(area: 'body', type: :html)
        d = @content.blocks.create!(area: 'body', type: :html, position: 3)
        @content.reload

        assert_equal(0, a.position)
        assert_equal(1, b.position)
        assert_equal(2, c.position)
        assert_equal(3, d.position)
      end

      def test_position_fixes_the_positions_on_destroy
        a = @content.blocks.create!(area: 'body', type: :html)
        b = @content.blocks.create!(area: 'body', type: :html)
        c = @content.blocks.create!(area: 'body', type: :html)
        b.destroy
        @content.reload

        assert_equal(0, a.position)
        assert_equal(1, c.position)
      end
    end
  end
end
