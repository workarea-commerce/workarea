require 'test_helper'

module Workarea
  class SvgAssetFinderTest < TestCase
    setup :setup_path

    def test_find_asset
      assert_kind_of(SvgAssetFinder, SvgAssetFinder.find_asset(@filename))
    end

    def test_pathname
      finder = SvgAssetFinder.new(@filename)
      asset_path = Admin::Engine.root.join("app/assets/images/#{@filename}")
      assert_equal(finder.pathname, asset_path)
    end

    def test_missing_pathname
      finder = SvgAssetFinder.new('bogus.svg')

      assert_nil(finder.pathname)
    end

    private

    def setup_path
      @filename = 'workarea/admin/icons/expand_more.svg'
    end
  end
end
