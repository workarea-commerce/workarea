require 'test_helper'

module Workarea
  module Admin
    class PromoCodesListIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_a_new_promo_code_list
        post admin.pricing_discount_code_lists_path,
          params: {
            code_list: {
              name:   'Test Code List',
              prefix: 'WL',
              count:  5
            }
          }

        assert_equal(1, Pricing::Discount::CodeList.count)
        code_list = Pricing::Discount::CodeList.first
        assert_equal('Test Code List', code_list.name)
        assert_equal('WL', code_list.prefix)
        assert_equal(5, code_list.count)
        assert_equal(5, code_list.promo_codes.length)
      end

      def test_updates_promo_code_list
        future_date = Time.current + 30.days
        code_list = create_code_list(expires_at: Time.current)

        patch admin.pricing_discount_code_list_path(code_list),
              params: {
                code_list: {
                  name: 'New Code List Name',
                  expires_at: future_date
                }
              }

        code_list.reload
        assert_equal('New Code List Name', code_list.name)
        assert_equal(future_date.to_i, code_list.expires_at.to_i)
        code_list.promo_codes.each do |code|
          assert_equal(future_date.to_i, code.expires_at.to_i)
        end
      end

      def test_removes_a_promo_code_list
        code_list = create_code_list
        delete admin.pricing_discount_code_list_path(code_list)
        assert(Pricing::Discount::CodeList.count.zero?)
      end

      def test_exporting_generated_codes
        code_list = create_code_list(count: 200)
        query = AdminSearchQueryWrapper.new(
          model_type: Pricing::Discount::GeneratedPromoCode,
          query_params: { code_list_id: code_list.id }
        )

        post admin.data_file_exports_path,
          params: {
            model_type: 'Workarea::Pricing::Discount::GeneratedPromoCode',
            query_id: query.to_gid_param,
            file_type: 'csv',
            export: { emails_list: 'test@workarea.com' }
          }

        export = DataFile::Export.desc(:created_at).first
        results = CSV.read(export.file.path)
        assert_equal(201, results.size)
      end
    end
  end
end
