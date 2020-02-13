require 'test_helper'

module Workarea
  module Admin
    class ContentHelperTest < ViewTest
      def test_options_for_category
        category = create_category
        deleted_category = create_category.tap(&:destroy)
        options = %(<option selected="selected" value="#{category.id}">#{category.name}</option>)

        assert_equal('', options_for_category(nil))
        assert_equal('', options_for_category(deleted_category.id))
        assert_equal(options, options_for_category(category.id))
      end
    end
  end
end
