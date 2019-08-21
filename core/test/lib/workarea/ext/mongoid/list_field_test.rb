require 'test_helper'

module Mongoid
  class ListFieldTest < Workarea::TestCase
    class ListDocument
      include Mongoid::Document
      field :some_ids, type: Array
      list_field :some_ids
    end

    def test_sets_parses_the_list_and_sets_the_array_values
      doc = ListDocument.new(some_ids_list: '1,2,3')
      assert_equal(%w(1 2 3), doc.some_ids)
    end

    def test_strips_whitespace_and_blank_values
      doc = ListDocument.new
      doc.some_ids_list = ' 1 ,  2,  ,,3  '
      assert_equal(%w(1 2 3), doc.some_ids)
    end

    def test_gets_a_list_with_commas_a_single_space
      doc = ListDocument.new(some_ids: %w(1 2 3))
      assert_equal('1, 2, 3', doc.some_ids_list)
    end
  end
end
