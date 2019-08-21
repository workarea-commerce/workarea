require 'test_helper'

module Workarea
  module DataFile
    class ImportTest < Workarea::TestCase
      def test_successful_process
        file = create_tempfile([create_product].to_json, extension: 'json')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        assert_equal('json', import.file_type)
        assert_nothing_raised { import.process! }

        import.reload
        assert_equal(1, import.total)
        assert_equal(1, import.succeeded)
        assert_equal(0, import.failed)
        assert(import.complete?)
        refute(import.error?)
        assert(import.successful?)
      end

      def test_a_validation_error
        sample = create_product
        sample.name = ''
        file = create_tempfile([sample].to_json, extension: 'json')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        assert_equal('json', import.file_type)
        assert_nothing_raised { import.process! }

        import.reload
        assert_equal(1, import.total)
        assert_equal(0, import.succeeded)
        assert_equal(1, import.failed)
        assert(import.complete?)
        refute(import.error?)
        refute(import.successful?)
      end

      def test_a_validation_error_with_bson_id
        sample = create_page
        sample.name = ''
        file = create_tempfile([sample].to_json, extension: 'json')

        import = create_import(
          model_type: Workarea::Content::Page,
          file: file
        )

        assert_equal('json', import.file_type)
        assert_nothing_raised { import.process! }

        import.reload
        assert_equal(1, import.total)
        assert_equal(0, import.succeeded)
        assert_equal(1, import.failed)
        assert(import.complete?)
        refute(import.error?)
        refute(import.successful?)
      end

      def test_an_unknown_file_type
        file = create_tempfile('foo', extension: 'bar')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        assert_raise(DataFile::UnknownFormatError) { import.process! }
        import.reload

        assert_equal('Workarea::DataFile::UnknownFormatError', import.error_type)
        assert(import.complete?)
        assert(import.error?)
        refute(import.successful?)
      end

      def test_an_invalid_file_format
        file = create_tempfile('{]}', extension: 'json')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        assert_raise { import.process! }
        import.reload

        assert(import.error_type.present?)
        assert(import.complete?)
        assert(import.error?)
        assert(import.failure?)
        refute(import.successful?)
      end
    end
  end
end
