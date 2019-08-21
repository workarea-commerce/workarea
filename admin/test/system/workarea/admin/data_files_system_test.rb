require 'test_helper'

module Workarea
  module Admin
    class DataFilesSystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      setup :user

      def user
        @user ||= create_user(
          admin: true,
          first_name: 'Bob',
          last_name: 'Clams'
        )
      end

      def test_viewing_imports
        tempfile = Tempfile.new

        Sidekiq::Callbacks.disable(ProcessImport) do
          import_one = create_import(
            created_by_id: user.id,
            started_at: 1.hour.ago,
            file: tempfile,
            file_type: 'csv',
            file_name: 'products_import.csv',
            error_type: 'FakeTestErrorType',
            error_message: 'test error message'
          )

          import_two = create_import(
            model_type: 'Workarea::Content::Page',
            created_by_id: user.id,
            started_at: 2.hour.ago,
            file: tempfile,
            file_type: 'json',
            file_name: 'pages_import.json',
            file_errors: {
              '12' => { name: ["can't be blank"] },
              '34' => { blocks: ["is invalid"] }
            }
          )

          tempfile.close

          visit admin.data_files_path

          assert(page.has_content?("2 #{t('workarea.admin.data_files.index.import')}"))
          assert(page.has_content?('Catalog Product'))
          assert(page.has_content?(import_one.file_name))
          assert(page.has_content?('Content Page'))
          assert(page.has_content?(import_two.file_name))
          assert(page.has_content?(user.name, count: 2))

          click_link '1'
          assert(page.has_content?('FakeTestErrorType'))
          assert(page.has_content?('test error message'))

          go_back
          click_link '2'

          assert(page.has_content?('12'))
          assert(page.has_content?('name'))
          assert(page.has_content?('can\'t be blank'))
          assert(page.has_content?('34'))
          assert(page.has_content?('blocks'))
          assert(page.has_content?('is invalid'))
        end
      end

      def test_viewing_exports
        Sidekiq::Callbacks.disable(ProcessExport) do
          export_one = create_export(
            created_by_id: user.id,
            started_at: 1.hour.ago,
            file_type: 'csv'
          )
          export_one.update_attributes!(
            file: export_one.tempfile.tap(&:close),
            completed_at: Time.current
          )

          export_two = create_export(
            model_type: Workarea::Order,
            query_id: Search::AdminOrders.new.to_global_id,
            created_by_id: user.id,
            started_at: 2.hour.ago,
            file_type: 'json'
          )
          export_two.update_attributes!(
            file: export_two.tempfile.tap(&:close),
            completed_at: Time.current
          )

          visit admin.data_files_path

          click_link t('workarea.admin.data_files.index.view_exports')

          assert(page.has_content?("2 #{t('workarea.admin.data_files.index.export')}"))
          assert(page.has_content?('Catalog Product'))
          assert(page.has_content?(export_one.file_name))
          assert(page.has_content?('Order'))
          assert(page.has_content?(export_two.file_name))
          assert(page.has_content?(user.name, count: 2))
        end
      end
    end
  end
end
