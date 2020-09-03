module Workarea
  module Admin
    class ReportsController < Admin::ApplicationController
      required_permissions :reports

      def average_order_value
        @report = Reports::AverageOrderValueViewModel.wrap(
          Workarea::Reports::AverageOrderValue.new(params),
          view_model_options
        )
      end

      def first_time_vs_returning_sales
        @report = Reports::FirstTimeVsReturningSalesViewModel.wrap(
          Workarea::Reports::FirstTimeVsReturningSales.new(params),
          view_model_options
        )
      end

      def insights
        @insights = Reports::InsightsViewModel.wrap(nil, view_model_options)
      end

      def customers
        @report = Reports::CustomersViewModel.wrap(
          Workarea::Reports::Customers.new(params),
          view_model_options
        )
      end

      def reference
        @terms =
          t('workarea.admin.reports.reference.terms')
            .sort_by(&:first)
            .map { |_key, term| OpenStruct.new(term) }
      end

      def sales_by_category
        @report = Reports::SalesByCategoryViewModel.wrap(
          Workarea::Reports::SalesByCategory.new(params),
          view_model_options
        )
      end

      def sales_by_country
        @report = Reports::SalesByCountryViewModel.wrap(
          Workarea::Reports::SalesByCountry.new(params),
          view_model_options
        )
      end

      def sales_by_discount
        @report = Reports::SalesByDiscountViewModel.wrap(
          Workarea::Reports::SalesByDiscount.new(params),
          view_model_options
        )
      end

      def sales_by_product
        @report = Reports::SalesByProductViewModel.wrap(
          Workarea::Reports::SalesByProduct.new(params),
          view_model_options
        )
      end

      def sales_by_traffic_referrer
        @report = Reports::SalesByTrafficReferrerViewModel.wrap(
          Workarea::Reports::SalesByTrafficReferrer.new(params),
          view_model_options
        )
      end

      def sales_by_sku
        @report = Reports::SalesBySkuViewModel.wrap(
          Workarea::Reports::SalesBySku.new(params),
          view_model_options
        )
      end

      def sales_by_tender
        @report = Reports::SalesByTenderViewModel.wrap(
          Workarea::Reports::SalesByTender.new(params),
          view_model_options
        )
      end

      def sales_over_time
        @report = Reports::SalesOverTimeViewModel.wrap(
          Workarea::Reports::SalesOverTime.new(params),
          view_model_options
        )
      end

      def searches
        @report = Reports::SearchesViewModel.wrap(
          Workarea::Reports::Searches.new(params),
          view_model_options
        )
      end

      def timeline
        @report = Reports::TimelineViewModel.wrap(
          Workarea::Reports::SalesOverTime.new(params.merge(group_by: 'day')),
          view_model_options
        )
      end

      def low_inventory
        @report = Reports::LowInventoryViewModel.wrap(
          Workarea::Reports::LowInventory.new(params),
          view_model_options
        )
      end

      def content_security_policy_violations
        @report = Reports::ContentSecurityPolicyViolationsViewModel.wrap(
          Workarea::Reports::ContentSecurityPolicyViolations.new(params),
          view_model_options
        )
      end

      def export
        export = Workarea::Reports::Export.new(params[:export])

        if export.save
          flash[:success] = t('workarea.admin.reports.flash_messages.success')
          redirect_back fallback_location: root_path
        else
          flash[:error] = export.errors.full_messages.to_sentence
          export.report_type.present? ? send(export.report_type) : redirect_to(root_path)
        end
      end

      def download
        export = Workarea::Reports::Export.find(params[:id])
        send_file export.file.file, filename: export.file_name
      end
    end
  end
end
