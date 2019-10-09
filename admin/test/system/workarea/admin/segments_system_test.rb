require 'test_helper'

module Workarea
  module Admin
    class SegmentsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_creating_a_segment
        visit admin.segments_path
        click_link 'add_segment'

        fill_in 'segment[name]', with: 'Philadelphians'
        click_button 'save_setup'

        assert(page.has_content?('Success'))
        select t('workarea.admin.fields.geolocation'), from: 'rule_type'
        click_button 'add_rule'

        fill_in 'rule[city]', with: 'Philadelphia'
        click_button 'save_rule'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Philadelphia'))

        click_link "#{t('workarea.admin.create_segments.rules.complete')} →"
        assert_current_path(admin.segment_path(Segment.first))

        visit admin.segments_path
        assert(page.has_content?('Philadelphians'))
      end

      def test_managing_segments
        create_life_cycle_segments
        visit admin.segments_path

        click_link 'Loyal Customer'
        click_link t('workarea.admin.segments.cards.attributes.header')

        fill_in 'segment[tag_list]', with: 'life-cycle'
        click_button 'save_segment'

        assert(page.has_content?('Success'))
        assert(page.has_content?('life-cycle'))

        click_link t('workarea.admin.segments.cards.rules.header')
        assert(page.has_content?(t('workarea.admin.segment_rules.index.no_edit')))
      end

      def test_managing_active_by_segment
        one = create_segment(name: 'Foo')
        two = create_segment(name: 'Bar')
        three = create_segment(name: 'Baz')

        category = create_category(active: false, active_segment_ids: [])
        visit admin.edit_catalog_category_path(category)

        within '.active-field' do
          refute_content(t('workarea.admin.shared.active_field.by_segment', count: 0))
          find('.toggle-button__label--negative').click
          assert_content(t('workarea.admin.shared.active_field.by_segment', count: 0))
        end

        find('[data-active-by-segment-tooltip]').click
        assert_content(t('workarea.admin.shared.active_field.active_by_segment'))

        find('.select2-selection--multiple').click
        find('.select2-results__option', text: 'Bar').click

        execute_script("$('body').trigger('click')")
        sleep(0.4) # Tooltipster's config of delay + animationDuration is 400ms

        assert_content(t('workarea.admin.shared.active_field.by_segment', count: 1, name: 'Bar'))
        click_button 'save_category'

        assert_content('Success')
        click_link 'Attributes'
        assert_content(t('workarea.admin.shared.active_field.by_segment', count: 1, name: 'Bar'))
        find('[data-active-by-segment-tooltip]').click

        assert_selector('.select2-selection__choice', text: 'Bar')

        find('.select2-selection--multiple').click
        find('.select2-results__option', text: 'Baz').click

        execute_script("$('body').trigger('click')")
        sleep(0.4) # Tooltipster's config of delay + animationDuration is 400ms

        assert_content(t('workarea.admin.shared.active_field.by_segment', count: 2, name: 'Bar', more_count: 1))
        click_button 'save_category'

        assert_content('Success')
        click_link 'Attributes'
        assert_content(t('workarea.admin.shared.active_field.by_segment', count: 1, name: 'Bar', more_count: 1))
        find('[data-active-by-segment-tooltip]').click

        assert_selector('.select2-selection__choice', text: 'Bar')
        assert_selector('.select2-selection__choice', text: 'Baz')
      end

      def test_insights
        segment = create_segment

        Metrics::SegmentByDay.inc(
          key: { segment_id: segment.id },
          at: Time.zone.local(2018, 10, 27),
          orders: 100,
          revenue: 555.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)

        visit admin.segment_path(segment)
        assert(page.has_content?('100'))
        assert(page.has_content?('555'))
        assert(page.has_content?('5.55'))

        click_link t('workarea.admin.segments.cards.insights.header')
        assert(page.has_content?('100'))
        assert(page.has_content?('555'))
        assert(page.has_content?('5.55'))
      end
    end
  end
end
