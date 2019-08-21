require 'test_helper'

module Workarea
  module Admin
    class DataFileExportsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_symmetrical_with_import
        one = create_product
        two = create_product

        Workarea.config.data_file_formats.each do |file_type|
          assert_no_changes 'Catalog::Product.first' do
            post admin.data_file_exports_path,
              params: {
                model_type: 'Workarea::Catalog::Product',
                ids: [one.to_global_id, two.to_global_id],
                file_type: file_type,
                export: { emails_list: 'test@workarea.com' }
              }

            export = DataFile::Export.desc(:created_at).first
            assert(File.read(export.file.path).present?)

            post admin.data_file_imports_path,
              params: {
                import: {
                  model_type: 'Workarea::Catalog::Product',
                  file: Rack::Test::UploadedFile.new(export.file.path)
                }
              }
          end
        end
      end

      def test_sends_an_email
        product = create_product # sample

        Workarea.config.data_file_formats.each do |file_type|
          ActionMailer::Base.deliveries.clear

          post admin.data_file_exports_path,
            params: {
              model_type: 'Workarea::Catalog::Product',
              query_id: Search::AdminProducts.new.to_global_id,
              file_type: file_type,
              export: { emails_list: 'test@workarea.com, foo@workarea.com' }
            }

          assert_equal(1, ActionMailer::Base.deliveries.size)
          email = ActionMailer::Base.deliveries.last
          export = DataFile::Export.desc(:created_at).first

          subject = t(
            'workarea.admin.data_file_mailer.export.subject',
            name: export.name.downcase
          )

          assert_equal(subject, email.subject)
          assert_includes(email.bcc, 'test@workarea.com')
          assert_includes(email.bcc, 'foo@workarea.com')
          email.parts.each do |part|
            assert_includes(part.body, admin.data_file_export_url(export))
          end
        end
      end
    end
  end
end
