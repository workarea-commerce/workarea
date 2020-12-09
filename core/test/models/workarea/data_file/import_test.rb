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

      def test_successful_process_for_a_release
        sample = create_product(name: 'Test Product')
        sample.name = 'Test Product Changed'
        file = create_tempfile([sample].to_json, extension: 'json')
        release = create_release

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file,
          release_id: release.id
        )

        assert_equal('json', import.file_type)
        assert_nothing_raised { import.process! }

        sample.reload
        assert_equal('Test Product', sample.name)

        Release.with_current(release) do
          assert_equal('Test Product Changed', sample.reload.name)
        end

        import.reload
        assert_equal(1, import.total)
        assert_equal(1, import.succeeded)
        assert_equal(0, import.failed)
        assert(import.complete?)
        refute(import.error?)
        assert(import.successful?)
      end

      def test_csv_embedded_changes_for_release
        release = create_release
        product = create_product(
          name: 'Foo',
          variants: [{ sku: '1', name: 'Bar' }, { sku: '2', name: 'Baz' }]
        )
        product.name = 'Foo Changed'
        product.variants.first.name = 'Bar Changed'

        import = create_import(
          model_type: product.class.name,
          file: create_tempfile(Csv.new.serialize(product), extension: 'csv'),
          file_type: 'csv',
          release_id: release.id
        )

        assert_equal('csv', import.file_type)
        assert_nothing_raised { import.process! }

        product.reload
        assert_equal('Foo', product.name)
        assert_equal('Bar', product.variants.first.name)
        assert_equal('Baz', product.variants.second.name)

        Release.with_current(release) do
          product.reload
          assert_equal('Foo Changed', product.name)
          assert_equal('Bar Changed', product.variants.first.name)
          assert_equal('Baz', product.variants.second.name)
        end

        import.reload
        assert_equal(2, import.total)
        assert_equal(2, import.succeeded)
        assert_equal(0, import.failed)
        assert(import.complete?)
        refute(import.error?)
        assert(import.successful?)
      end

      def test_large?
        product = create_product
        file = create_tempfile([product].to_json, extension: 'json')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        Workarea.config.data_file_import_large_json_threshold = file.size - 1
        assert(import.large?)
        Workarea.config.data_file_import_large_json_threshold = file.size + 1
        refute(import.large?)

        file = create_tempfile(Csv.new.serialize(product), extension: 'csv')

        import = create_import(
          model_type: Workarea::Catalog::Product,
          file: file
        )

        Workarea.config.data_file_import_large_csv_threshold = file.size - 1
        assert(import.large?)
        Workarea.config.data_file_import_large_csv_threshold = file.size + 1
        refute(import.large?)
      end
    end
  end
end
