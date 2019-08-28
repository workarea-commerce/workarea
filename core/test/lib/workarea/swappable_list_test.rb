require 'test_helper'

module Workarea
  class SwappableListTest < TestCase
    setup :set_list

    def set_list
      @list = SwappableList.new([:one, :two, :three])
    end

    def test_inserts_at_the_index
      @list.insert(1, :one_and_a_half)
      assert_equal(:one_and_a_half, @list[1])
    end

    def test_inserts_the_value_after_the_index
      @list.insert_after(1, :two_and_a_half)
      assert_equal(:two_and_a_half, @list[2])
    end

    def test_swap_changes_the_value_at_the_index
      @list.swap(:two, :TWO)
      assert_equal(:TWO, @list[1])
    end

    def test_delete_changes_the_value_at_the_index
      @list.delete(:three)
      assert_equal(2, @list.size)
    end

    def test_returns_a_new_swappable_list_with_element_added
      @list = SwappableList.new([:one, :two, :three])
      @list += :four
      assert_instance_of(SwappableList, @list)
      assert_includes(@list, :four)
    end

    def test_returns_a_new_swappable_list_with_element_removed
      @list = SwappableList.new([:one, :two, :three])
      @list -= :three
      assert_instance_of(SwappableList, @list)
      refute_includes(@list, :three)
    end

    def test_deep_dup
      config_1 = ActiveSupport::OrderedOptions.new
      config_1.list = SwappableList.new([:foo])
      config_2 = config_1.deep_dup

      config_2.list.swap(:foo, :bar)

      assert_equal([:foo], config_1.list.to_a)
      assert_equal([:bar], config_2.list.to_a)
    end
  end
end
