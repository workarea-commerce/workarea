require 'test_helper'

module Workarea
  class StyleGuidesHelperTest < ViewTest
    include Admin::Engine.routes.url_helpers

    def test_partial_paths
      partials = StyleGuidesHelper::Partials.new(
        Storefront::Engine.root,
        'storefront',
        'settings'
      )

      assert_includes(
        partials.to_a,
        'workarea/storefront/style_guides/settings/color_variables'
      )

      partials = StyleGuidesHelper::Partials.new(
        Admin::Engine.root,
        'admin',
        'settings'
      )

      assert_includes(
        partials.to_a,
        'workarea/admin/style_guides/settings/color_variables'
      )
    end

    def test_adds_an_anchor_to_a_style_guide_modifier
      result = link_to_style_guide('foo', 'bar__baz')

      assert_includes(result, '/bar#bar--baz')
    end

    def test_adds_a_custom_anchor_to_a_style_guide_modifier
      result = link_to_style_guide('foo', 'bar__baz', false, 'bat')

      assert_includes(result, '/bar#bar--baz')
      assert_includes(result, '>bat</a>')
    end

    def test_style_guide_icons
      stubs(:parent_module).returns(Workarea::Storefront)
      filenames = style_guide_icons.map { |i| File.basename(i) }
      facebook_icons = filenames.select { |n| n == 'facebook.svg' }

      assert_includes(filenames, 'facebook.svg')
      assert_equal(1, facebook_icons.length)
    end

    def test_style_guide_icons_maintain_alphanumeric_sort_order
      stubs(:parent_module).returns(Workarea::Storefront)

      filenames = style_guide_icons.map { |i| File.basename(i) }
      facebook_icon_index = filenames.find_index('facebook.svg')
      twitter_icon_index = filenames.find_index('twitter.svg')

      assert_operator(facebook_icon_index, :<, twitter_icon_index)
    end
  end
end
