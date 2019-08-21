require 'test_helper'
require 'generators/workarea/js_adapter/js_adapter_generator'

module Workarea
  class OverrideGeneratorTest < GeneratorTest
    tests Workarea::JsAdapterGenerator
    destination Dir.mktmpdir
    setup :prepare_destination

    def test_copying_files
      run_generator %w(testAdapter)
      assert_file 'app/assets/javascripts/workarea/storefront/adapters/test_adapter.js'
    end
  end
end
