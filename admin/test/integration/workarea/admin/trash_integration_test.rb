require 'test_helper'

module Workarea
  module Admin
    class TrashIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def last_audit_log_entry
        Mongoid::AuditLog::Entry.desc(:created_at).first
      end

      def test_restore
        category = create_category(
          name: 'My Category',
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )

        delete admin.catalog_category_path(category)
        assert(Catalog::Category.empty?)

        post admin.restore_trash_path(last_audit_log_entry)
        assert_redirected_to(admin.catalog_category_path(category))

        assert_equal(1, Catalog::Category.count)
        category.reload

        assert_equal('My Category', category.name)
        assert_equal('search', category.product_rules.first.name)
      end

      def test_restoring_an_embedded_document
        category = create_category(
          name: 'My Category',
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )

        delete admin.product_list_product_rule_path(
          category.to_global_id,
          category.product_rules.first
        )

        assert(category.reload.product_rules.empty?)

        post admin.restore_trash_path(last_audit_log_entry)
        assert_redirected_to(admin.catalog_category_path(category))

        category.reload
        assert_equal(1, category.product_rules.length)
        assert_equal('search', category.product_rules.first.name)
      end

      def test_restoring_taxonomy
        taxon = create_taxon
        Mongoid::AuditLog.record { taxon.destroy }

        post admin.restore_trash_path(last_audit_log_entry)
        assert_redirected_to(admin.navigation_taxons_path(taxon_ids: taxon.parent_ids))
      end

      def test_restoring_content_blocks
        content = create_content
        block = content.blocks.create!(type: :html)
        Mongoid::AuditLog.record { block.destroy }

        post admin.restore_trash_path(last_audit_log_entry)
        assert_redirected_to(admin.edit_content_path(content))
      end

      def test_restoring_assets
        asset = create_asset
        Mongoid::AuditLog.record { asset.destroy }

        post admin.restore_trash_path(last_audit_log_entry)

        assert(response.redirect?)
        assert(asset.reload)
      end

      def test_restoring_comments
        product = create_product
        comment = create_comment(commentable: product)

        Mongoid::AuditLog.record { comment.destroy }
        audit_log_entry = Mongoid::AuditLog::Entry.first

        post admin.restore_trash_path(audit_log_entry)
        assert(comment.reload)
        assert_redirected_to(
          admin.commentable_comments_path(product.to_global_id)
        )
      end

      def test_restoring_without_permission
        user = create_user(
          email: 'test@workarea.com',
          admin: true,
          catalog_access: true,
          can_restore: false
        )
        set_current_user(user)

        category = create_category

        delete admin.catalog_category_path(category)
        assert(Catalog::Category.empty?)

        post admin.restore_trash_path(last_audit_log_entry),
          headers: { 'HTTP_REFERER' => admin.trash_index_path }

        assert_redirected_to(admin.trash_index_path)
        assert_equal(
          I18n.t('workarea.admin.trash.flash_messages.unauthorized'),
          flash[:error]
        )
        assert(Catalog::Category.empty?)
      end

      def test_restoring_with_validation_failures
        delete admin.catalog_product_path(create_product(slug: 'slug'))
        create_product(slug: 'slug')

        post admin.restore_trash_path(last_audit_log_entry)
        assert_redirected_to(admin.trash_index_path)
        assert(flash[:error].present?)
      end

      def test_restored_items_not_included_in_trash
        category = create_category

        Mongoid::AuditLog.record { category.destroy }
        entry = last_audit_log_entry
        get admin.trash_index_path

        assert_response(:success)
        assert_includes(response.body, category.name)

        entry.restore!
        get admin.trash_index_path

        assert_response(:success)
        refute_includes(response.body, category.name)
      end
    end
  end
end
