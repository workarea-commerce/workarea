require 'test_helper'

module Workarea
  class FindPipelineAssetTest < TestCase

    def test_path
      path = FindPipelineAsset.new('foo.png').path
      assert(path.to_s.ends_with?('/app/assets/images/workarea/core/foo.png'), path)

      name = 'placeholder.png'
      path = FindPipelineAsset.new(name).path
      assert_includes(path.to_s, "app/assets/images/workarea/core/#{name}")

      path = FindPipelineAsset.new('foo', path: %w(data workarea core)).path
      assert_includes(path.to_s, 'data/workarea/core/foo')

      path = FindPipelineAsset.new('test.jpg').path
      assert_includes(path.to_s, 'storefront')
    end
  end
end
