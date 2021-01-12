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
        within '.calendar__day--today' do
          click_link t('workarea.admin.releases.calendar.add_new_release')
        end

        fill_in 'release[name]', with: 'Foo Release'
        click_button 'save_setup'
      end

      def make_page_change
        visit admin.content_page_path(@content_page)
        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'page[name]', with: 'Foo Bar'
        click_button 'save'
      end

      def test_list_search
        create_release(name: 'Scheduled Release', publish_at: 1.week.from_now)
        create_release(name: 'Unscheduled Release')
        create_release(name: 'Published Release', published_at: 1.week.ago)

        visit admin.list_releases_path

        within '#release_search_form' do
          fill_in 'q', with: 'release'
          click_button 'search_releases'
        end

        assert(page.has_content?('Scheduled Release'))
        assert(page.has_content?('Unscheduled Release'))
        assert(page.has_content?('Published Release'))

        within '.browsing-controls' do
          click_button 'Publishing'
          click_link 'Published (1)'
        end

        refute_text('Scheduled Release')
        refute_text('Unscheduled Release')
        assert(page.has_content?('Published Release'))

        click_link t('workarea.admin.facets.applied.clear_all')
        assert(page.has_content?('Scheduled Release'))
        assert(page.has_content?('Unscheduled Release'))
        assert(page.has_content?('Published Release'))

        within '.browsing-controls__filter--date' do
          find('.browsing-controls__filter-button').click
          fill_in 'published_at_greater_than', with: 2.weeks.ago.to_s(:date_only)
          click_button 'filter_by_creation_date'
        end

        refute(page.has_content?('Scheduled Release'))
        refute(page.has_content?('Unscheduled Release'))
        assert(page.has_content?('Published Release'))
      end

      def test_saving_changes_for_a_release
        create_the_release
        make_page_change

        assert_equal(admin.content_page_path(@content_page), current_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Foo Release'))
        assert(page.has_content?('Foo Bar'))

        select t('workarea.admin.releases.select.live_site'), from: 'release_id'

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
        # Set Publishing, through Calendar
        #
        #
        visit admin.releases_path
        find('.calendar__release', text: 'Foo Release').click

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'release_publish_at_date', with: 1.day.from_now.strftime('%Y-%m-%d')
        click_button 'save_release'
        assert(page.has_content?('Success'))

        #
        # Delete, through Releases List
        #
        #
        visit admin.list_releases_path
        click_link 'Foo Release'

        click_on t('workarea.admin.actions.delete')
        assert(page.has_current_path?(admin.releases_path))
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Foo Release'))
      end

      def test_viewing_release_changes
        Workarea.config.release_large_change_count_threshold = 2

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
        assert(page.has_content?('2 Products'))
        assert(page.has_content?('1 Pricing Sku'))
        assert(page.has_content?('1 Discount'))
        assert(page.has_content?('1 System Page'))
        assert(page.has_content?(t('workarea.admin.releases.show.large_changeset_warning')))

        click_link t('workarea.admin.releases.cards.planned_changes.planned')
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
        click_link t('workarea.admin.timeline.card.title')

        assert(page.has_content?('Test Page'))
        assert(page.has_content?('Foo Bar'))

        click_button t('workarea.admin.timeline.edit')
        assert_current_path(admin.content_page_path(@content_page))
        click_link t('workarea.admin.cards.attributes.title')
        assert_equal('Foo Bar', find_field('page[name]').value)
      end

      def test_publising_a_release
        create_the_release
        make_page_change

        visit admin.releases_path
        find('.calendar__release', text: 'Foo Release').click

        click_button t('workarea.admin.releases.show.publish_now')
        assert(page.has_content?('Success'))

        visit admin.edit_content_page_path(@content_page)
        assert_equal('Foo Bar', find_field('page[name]').value)
      end

      def test_inline_release_creation
        visit admin.edit_content_page_path(@content_page)
        select t('workarea.admin.js.publish_with_release_menus.a_new_release'), from: 'release_id'

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

        select t('workarea.admin.js.publish_with_release_menus.a_new_release'), from: 'publishing'
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

      def test_creating_a_release_undo
        visit admin.edit_content_page_path(@content_page)
        select t('workarea.admin.js.publish_with_release_menus.a_new_release'), from: 'release_id'

        within '#release_form' do
          fill_in 'release[name]', with: 'Foo Release'
          click_button 'save_release'
        end

        wait_for_xhr
        make_page_change

        visit admin.list_releases_path
        click_link 'Foo Release'
        click_link t('workarea.admin.releases.show.build_undo')

        fill_in 'release[name]', with: 'Foo Bar Undo'
        click_button t('workarea.admin.create_release_undos.workflow.create_undo')
        assert(page.has_content?('Test Page'))
        assert(page.has_content?('Foo Bar'))

        click_link "#{t('workarea.admin.create_release_undos.workflow.done')} →"
        assert(page.has_content?('Foo Bar Undo'))
        assert(page.has_content?('1 Content Page'))

        click_link t('workarea.admin.releases.cards.planned_changes.planned')
        assert(page.has_content?('Test Page'))
        assert(page.has_content?('Foo Bar'))
      end

      def test_release_calendar
        create_the_release
        make_page_change

        visit admin.releases_path
        find('.calendar__release', text: 'Foo Release').click

        click_button t('workarea.admin.releases.show.publish_now')
        assert(page.has_content?('Success'))

        visit admin.releases_path

        assert(find('.calendar').has_content?('Foo Release'))

        click_link t('workarea.admin.releases.calendar.next_week')
        wait_for_xhr
        assert(find('.calendar').has_content?('Foo Release'))

        click_link t('workarea.admin.releases.calendar.next_week')
        wait_for_xhr
        refute_text('Foo Release')

        click_link t('workarea.admin.releases.calendar.previous_week')
        wait_for_xhr
        assert(find('.calendar').has_content?('Foo Release'))

        click_link t('workarea.admin.releases.calendar.next_week')
        wait_for_xhr
        refute_text('Foo Release')

        click_button t('workarea.admin.releases.calendar.today')
        wait_for_xhr
        assert(find('.calendar').has_content?('Foo Release'))
      end

      def test_release_overflow
        #
        # Test maximum releases per day
        #
        #
        current_time = Time.current

        create_release(name: 'Release One', published_at: current_time)
        create_release(name: 'Release Two', published_at: current_time)
        create_release(name: 'Release Three', published_at: current_time)
        create_release(name: 'Release Four', published_at: current_time)
        create_release(name: 'Release Five', published_at: current_time)

        visit admin.releases_path

        assert(page.has_content?('Release One'))
        assert(page.has_content?('Release Two'))
        assert(page.has_content?('Release Three'))
        assert(page.has_content?('Release Four'))
        assert(page.has_content?('Release Five'))

        #
        # Test Overflow UI
        #
        #
        create_release(name: 'Release Six', published_at: current_time)

        visit admin.releases_path

        refute_text('Release Five')
        refute_text('Release Six')

        assert(
          page.has_content?(
            t('workarea.admin.releases.calendar.plus_more_releases', count: 2)
          )
        )

        find('.calendar__release[data-tooltip]').hover

        within '.tooltipster-content' do
          assert(page.has_content?('Release One'))
          assert(page.has_content?('Release Two'))
          assert(page.has_content?('Release Three'))
          assert(page.has_content?('Release Four'))
          assert(page.has_content?('Release Five'))
          assert(page.has_content?('Release Six'))
        end
      end

      def test_viewing_large_changesets
        Workarea.config.per_page = 2

        release = create_release
        product_one = create_product(id: 'PROD1', name: 'Product One')
        product_two = create_product(id: 'PROD2', name: 'Product Two')
        content_page = create_page(name: 'Test Page')

        release.as_current do
          product_one.variants.first.update!(details: { 'Color' => 'Orange' })
          product_two.update!(name: 'Test Product Changed')
          content_page.update!(name: 'Test Page Changed')
        end

        visit admin.release_path(release)

        assert(page.has_content?('2 Products'))
        assert(page.has_content?('1 Content Page'))

        click_link t('workarea.admin.releases.cards.planned_changes.planned')

        assert(page.has_content?('2 Products'))
        assert(page.has_content?('1 Content Page'))

        assert(page.has_content?('Test Product Changed'))
        assert(page.has_content?('Test Page Changed'))
        assert(page.has_no_content?('Orange'))

        assert(page.has_content?(t('workarea.admin.changesets.recent')))
        assert(page.has_content?(t('workarea.admin.cards.more', amount: 1)))

        click_link '2 Products'

        assert(page.has_content?('Product One'))
        assert(page.has_content?('Product Two'))
      end
    end
  end
end
