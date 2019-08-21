require 'test_helper'

module Workarea
  module Admin
    class DataFileImportsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_data
        sample = create_product

        Workarea.config.data_file_formats.each do |file_type|
          sample.name = "Changed by #{file_type}"
          format = "Workarea::DataFile::#{file_type.camelize}".constantize.new
          file = create_tempfile(format.serialize(sample), extension: file_type)

          assert_changes -> { sample.reload.name }, to: "Changed by #{file_type}" do
            post admin.data_file_imports_path,
              params: {
                return_to: admin.catalog_products_path,
                import: {
                  model_type: 'Workarea::Catalog::Product',
                  file: Rack::Test::UploadedFile.new(file.path)
                }
              }

            assert_redirected_to(admin.catalog_products_path)
          end
        end

        assert_equal(Workarea.config.data_file_formats.size, DataFile::Import.count)
        assert_equal(1, Catalog::Product.count)

        import = DataFile::Import.first
        assert(import.created_by_id.present?)
      end

      def test_retains_types
        Workarea.config.data_file_formats.each do |file_type|
          name = "#{file_type} Free Gift"
          input = Pricing::Discount::FreeGift.new(
            name: name,
            sku: 'SKU123'
          )

          format = "Workarea::DataFile::#{file_type.camelize}".constantize.new
          file = create_tempfile(format.serialize(input), extension: file_type)

          post admin.data_file_imports_path,
            params: {
              return_to: admin.pricing_discounts_path,
              import: {
                model_type: 'Workarea::Pricing::Discount',
                file: Rack::Test::UploadedFile.new(file.path)
              }
            }

          assert_redirected_to(admin.pricing_discounts_path)

          discount = Pricing::Discount.last

          refute_nil(discount)
          assert_kind_of(Pricing::Discount::FreeGift, discount)
          assert_equal(name, discount.name)
          assert_equal('SKU123', discount.sku)
        end
      end

      def test_can_create_an_import_from_the_sample
        2.times { create_product } # sample

        Workarea.config.data_file_formats.each do |file_type|
          get admin.sample_data_file_imports_path,
            params: {
              import: {
                model_type: 'Workarea::Catalog::Product',
                file_type: file_type
              }
            }

          file = create_tempfile(response.body, extension: file_type)
          assert(IO.read(file.path).present?)

          assert_no_changes 'Catalog::Product.first' do
            post admin.data_file_imports_path,
              params: {
                import: {
                  model_type: 'Workarea::Catalog::Product',
                  file: Rack::Test::UploadedFile.new(file.path)
                }
              }
          end
        end
      end

      def test_sends_an_email
        file = create_tempfile([create_product].to_json, extension: 'json')

        post admin.data_file_imports_path,
          params: {
            import: {
              model_type: 'Workarea::Catalog::Product',
              file: Rack::Test::UploadedFile.new(file.path)
            }
          }

        email = ActionMailer::Base.deliveries.last
        import = DataFile::Import.first

        subject = t(
          'workarea.admin.data_file_mailer.import.subject',
          type: import.name.downcase,
          file: import.file_name
        )

        assert_equal(subject, email.subject)
      end

      def test_saving_an_error
        file = create_tempfile('asdf', extension: 'json')

        assert_raise do
          post admin.data_file_imports_path,
            params: {
              import: {
                model_type: 'Workarea::Catalog::Product',
                file: Rack::Test::UploadedFile.new(file.path)
              }
            }
        end

        assert_equal(1, DataFile::Import.count)
        assert_equal(0, Catalog::Product.count)

        import = DataFile::Import.first
        assert(import.created_by_id.present?)
        assert(import.error_type.present?)
        assert(import.error_message.present?)
        assert(import.failure?)

        email = ActionMailer::Base.deliveries.last
        import = DataFile::Import.first

        subject = t(
          'workarea.admin.data_file_mailer.import_error.subject',
          type: import.name.downcase,
          file: import.file_name
        )

        assert_equal(subject, email.subject)
      end
    end
  end
end
