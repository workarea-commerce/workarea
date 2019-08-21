require 'test_helper'

module Workarea
  module DataFile
    class OperationTest < TestCase
      def test_samples
        sample = [create_product, create_product]
        import = create_import(model_type: Workarea::Catalog::Product)
        assert_equal(Workarea.config.data_file_sample_size, import.samples.size)
      end

      def test_no_samples_available
        import = create_import(model_type: Workarea::Catalog::Product)
        assert_equal(0, import.samples.size)
      end
    end
  end
end
