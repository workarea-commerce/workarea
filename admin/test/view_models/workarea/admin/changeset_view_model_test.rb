require 'test_helper'

module Workarea
  module Admin
    class ChangesetViewModelTest < TestCase
      setup :set_release, :set_releasable, :set_changeset, :set_view_model

      def set_release
        @release = create_release
      end

      def set_releasable
        @releasable = create_page
      end

      def set_changeset
        @changeset = @releasable.changesets.create!(
          release: @release,
          document_path: @releasable.document_path
        )
      end

      def set_view_model
        @view_model = ChangesetViewModel.wrap(@changeset)
      end

      def test_localized_change
        refute(@view_model.localized_change?(:template, 'en' => 'foo'))
        refute(@view_model.localized_change?(:name, 'foo'))
        assert(@view_model.localized_change?(:name, 'en' => 'foo'))
      end

      def test_current_change
        pricing_sku = create_pricing_sku
        changeset = pricing_sku.changesets.create!(
          release: @release,
          document_path: pricing_sku.document_path
        )
        view_model = ChangesetViewModel.wrap(changeset)

        refute(@view_model.currency_change?(:name, 'en' => 'foo'))
        refute(view_model.currency_change?(:msrp, 'foo'))
        assert(view_model.currency_change?(:msrp, 'cents' => 1200, 'currency_iso' => 'USD'))
      end

      def test_new_value_for
        @changeset.update_attributes!(
          changeset: { 'name' => { I18n.locale.to_s => 'foo' }}
        )

        assert_equal('foo', @view_model.new_value_for('name'))
      end

      def test_old_value_for
        @releasable.update_attributes!(name: 'foo')
        @changeset.update_attributes!(changeset: { 'name' => 'bar' })

        assert_equal('foo', @view_model.old_value_for('name'))

        @changeset.update_attributes!(
          changeset: { 'name' => 'baz' },
          undo: { 'name' => 'bar' }
        )

        assert_equal('bar', @view_model.old_value_for('name'))

        @changeset.update_attributes!(undo: { 'name' => { 'en' => 'baz' } })
        assert_equal('baz', @view_model.old_value_for('name'))
      end
    end
  end
end
