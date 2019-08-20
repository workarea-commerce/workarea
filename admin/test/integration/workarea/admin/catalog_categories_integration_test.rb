require 'test_helper'

module Workarea
  module Admin
    class CatalogCategoriesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_prevent_deletion_when_referenced_in_content
        category = create_category
        content = Content.for('Home Page')
        message = t('workarea.admin.catalog_categories.flash_messages.still_referenced', content: content.name)

        content.blocks.create!(type: :category_summary, data: { category: category.id.to_s })
        delete admin.catalog_category_path(category)

        assert_equal(message, flash[:error])
        assert(category.reload.persisted?, 'category was deleted')
      end
    end
  end
end
