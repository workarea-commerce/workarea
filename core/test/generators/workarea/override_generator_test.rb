require 'test_helper'
require 'generators/workarea/override/override_generator'

module Workarea
  class OverrideGeneratorTest < GeneratorTest
    tests Workarea::OverrideGenerator
    destination Dir.mktmpdir
    setup :prepare_destination

    def test_copying_files
      run_generator %w(views workarea/admin/catalog_products/index.html.haml)
      assert_file 'app/views/workarea/admin/catalog_products/index.html.haml'
      assert_file 'app/views/workarea/admin/catalog_products/index.json.jbuilder'
    end
  end
end
