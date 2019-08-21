require 'test_helper'

module Workarea
  module Admin
    class ReleasesSystemTest < SystemTest
      include Admin::IntegrationTest

      setup :set_content_page

      def set_content_page
        @content_page = create_page(name: 'Test Page')
      end

      def create_the_release
        visit admin.releases_path
        click_link 'add_release'

        fill_in 'release[name]', with: 'Foo Release'
        click_button 'save_setup'
      end

      def make_page_change
        visit admin.content_page_path(@content_page)
        click_link 'Attributes'
        fill_in 'page[name]', with: 'Foo Bar'
        click_button 'save'
      end

      def test_search
        create_release(name: 'Scheduled Release', publish_at: 1.week.from_now)
        create_release(name: 'Unscheduled Release')
        create_release(name: 'Published Release', published_at: 1.week.ago)
        create_release(name: 'Undone Release', published_at: 2.week.ago, undone_at: 1.day.ago)
        create_release(name: 'Scheduled Undo Release', published_at: 3.week.ago, undo_at: 1.day.from_now)

        visit admin.releases_path

        within '#release_search_form' do
          fill_in 'q', with: 'release'
          click_button 'search_releases'
        end

        assert(page.has_content?('Scheduled Release'))
        assert(page.has_content?('Unscheduled Release'))
        assert(page.has_content?('Published Release'))
        assert(page.has_content?('Undone Release'))
        assert(page.has_content?('Scheduled Undo Release'))

        within '.browsing-controls' do
          click_button 'Publishing'
          click_link 'Published (3)'
        end

        refute(page.has_content?('Scheduled Release'))
        refute(page.has_content?('Unscheduled Release'))
        assert(page.has_content?('Published Release'))
        assert(page.has_content?('Undone Release'))
        assert(page.has_content?('Scheduled Undo Release'))
      end

      def test_saving_changes_for_a_release
        create_the_release
        make_page_change

        assert_equal(admin.content_page_path(@content_page), current_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo Release'))
        assert(page.has_content?('Foo Bar'))

        select 'the live site', from: 'release_id'

        wait_for_xhr

        visit admin.content_pages_path
        assert(page.has_content?('Test Page'))
        assert(page.has_no_content?('Foo Bar'))
      end

      def test_managing_a_release
        #
        # Create release
        #
        #
        create_the_release
        assert(page.has_content?('Success'))
        make_page_change

        #
        # Set publishing
        #
        #
        visit admin.releases_path
        click_link 'Foo Release'

        click_link 'Attributes'
        fill_in 'release_publish_at_date', with: (Time.current + 1.day).strftime('%Y-%m-%d')
        fill_in 'release_undo_at_date', with: (Time.current + 1.week).strftime('%Y-%m-%d')
        click_button 'save_release'
        assert(page.has_content?('Success'))

        #
        # Delete
        #
        #
        visit admin.releases_path
        click_link 'Foo Release'

        click_on 'Delete'
        assert(page.has_current_path?(admin.releases_path))
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Foo Release'))
      end

      def test_viewing_release_changes
        create_the_release
        make_page_change
        product = create_product(name: 'Test Product', variants: [{ sku: 'SKU1' }])
        pricing_sku = create_pricing_sku(id: 'SKU123', tax_code: '001')
        discount = create_product_discount
        content = Content.for('Home Page')
        content.blocks.create!(area: 'test', type: 'html', data: { 'foo' => 'bar' })

        Release.first.as_current do
          product.update_attributes!(name: 'Changed Product')
          product.variants.first.update_attributes!(active: false)
          pricing_sku.update_attributes!(tax_code: '002')
          discount.update_attributes!(product_ids: [product.id])
          content.blocks.first.update_attributes!(data: { 'foo' => 'baz' })
        end

        visit admin.release_path(Release.first)
        click_link 'Planned Changes'
        assert(page.has_content?('Test Page'))
        assert(page.has_content?('Foo Bar'))
        assert(page.has_content?('Test Product'))
        assert(page.has_content?('Changed Product'))
        assert(page.has_content?('Foo'))
        assert(page.has_content?('bar'))
        assert(page.has_content?('baz'))
        assert(page.has_content?('001'))
        assert(page.has_content?('002'))
        assert(page.has_content?('Test Product - SKU1'))

        visit admin.content_page_path(@content_page)
        click_link 'Timeline'

        assert(page.has_content?('Test Page'))
        assert(page.has_content?('Foo Bar'))

        click_button 'Edit'
        assert_current_path(admin.content_page_path(@content_page))
        click_link 'Attributes'
        assert_equal('Foo Bar', find_field('page[name]').value)
      end

      def test_publising_a_release
        create_the_release
        make_page_change

        visit admin.releases_path
        click_link 'Foo Release'

        click_button 'Publish Now'
        assert(page.has_content?('Success'))

        visit admin.edit_content_page_path(@content_page)
        assert_equal('Foo Bar', find_field('page[name]').value)

        visit admin.releases_path
        click_link 'Foo Release'

        click_button 'Undo'
        assert(page.has_content?('Success'))

        visit admin.edit_content_page_path(@content_page)
        assert_equal('Test Page', find_field('page[name]').value)
      end

      def test_inline_release_creation
        visit admin.edit_content_page_path(@content_page)
        select 'a new release', from: 'release_id'

        within '#release_form' do
          fill_in 'release[name]', with: 'Foo Release'
          click_button 'save_release'
        end

        wait_for_xhr

        visit admin.content_page_path(@content_page)
        assert(page.has_select?('release_id', selected: 'Foo Release'))
      end

      def test_async_inline_release_creation
        create_the_release

        visit admin.edit_content_page_path(@content_page)

        fill_in 'page[name]', with: 'Foo Page'
        click_button 'save_page'

        assert_current_path(admin.content_page_path(@content_page))
        assert(page.has_select?('release_id', selected: 'Foo Release'))

        visit admin.edit_content_page_path(@content_page)

        fill_in 'page[name]', with: 'Bar Page'

        select 'a new release', from: 'publishing'
        within '#release_form' do
          fill_in 'release[name]', with: 'Bar Release'
          click_button 'save_release'
        end

        wait_for_xhr

        assert(page.has_select?('release_id', selected: 'Foo Release'))
        assert(page.has_select?('publishing', selected: 'Bar Release'))

        click_button 'save_page'

        assert(page.has_select?('release_id', selected: 'Bar Release'))
        assert(page.has_content?('Bar Page'))

        select 'Foo Release', from: 'release_id'
        wait_for_xhr

        assert(page.has_content?('Foo Page'))
      end
    end
  end
end
