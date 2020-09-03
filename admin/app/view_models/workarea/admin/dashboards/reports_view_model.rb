module Workarea
  module Admin
    module Dashboards
      class ReportsViewModel < ApplicationViewModel
        def country_graph_data
          sales_by_country.results.take(5).reduce({}) do |memo, result|
            memo.merge(result['_id'] => result['revenue'])
          end
        end

        def tender_graph_data
          sales_by_tender.results.take(5).reduce({}) do |memo, result|
            memo.merge(result.name => result.revenue)
          end
        end

        def insights
          @insights ||= Reports::InsightsViewModel.wrap(nil, options).feed
        end

        def marketing
          @marketing ||= Dashboards::MarketingViewModel.wrap(nil, options)
        end

        def sales_over_time
          @sales_over_time = Reports::SalesOverTimeViewModel.wrap(
            Workarea::Reports::SalesOverTime.new(options),
            options
          )
        end

        def average_order_value
          @average_order_value ||= Reports::AverageOrderValueViewModel.wrap(
            Workarea::Reports::AverageOrderValue.new(options),
            options
          )
        end

        def sales_by_product
          @sales_by_product ||= Reports::SalesByProductViewModel.wrap(
            Workarea::Reports::SalesByProduct.new(options),
            options
          )
        end

        def sales_by_category
          @sales_by_category ||= Reports::SalesByCategoryViewModel.wrap(
            Workarea::Reports::SalesByCategory.new(options),
            options
          )
        end

        def sales_by_sku
          @sales_by_sku ||= Reports::SalesBySkuViewModel.wrap(
            Workarea::Reports::SalesBySku.new(options),
            options
          )
        end

        def sales_by_discount
          @sales_by_discount ||= Reports::SalesByDiscountViewModel.wrap(
            Workarea::Reports::SalesByDiscount.new(options),
            options
          )
        end

        def sales_by_country
          @sales_by_country ||= Reports::SalesByCountryViewModel.wrap(
            Workarea::Reports::SalesByCountry.new(options),
            options
          )
        end

        def sales_by_tender
          @sales_by_tender ||= Reports::SalesByTenderViewModel.wrap(
            Workarea::Reports::SalesByTender.new(options),
            options
          )
        end

        def one_time_customers
          @one_time_customers ||= Reports::OneTimeCustomersViewModel.wrap(
            Workarea::Reports::OneTimeCustomers.new(options),
            options
          )
        end

        def customers
          @customers ||= Reports::CustomersViewModel.wrap(
            Workarea::Reports::Customers.new(options),
            options
          )
        end

        def first_time_vs_returning_sales
          @first_time_vs_returning_sales ||= Reports::FirstTimeVsReturningSalesViewModel.wrap(
            Workarea::Reports::FirstTimeVsReturningSales.new(options),
            options
          )
        end

        def searches
          @searches ||= Reports::SearchesViewModel.wrap(
            Workarea::Reports::Searches.new(options),
            options
          )
        end

        def low_inventory
          @low_inventory ||= Reports::LowInventoryViewModel.wrap(
            Workarea::Reports::LowInventory.new(options),
            options
          )
        end

        def content_security_policy_violations
          @content_security_policy_violations ||=
            Reports::ContentSecurityPolicyViolationsViewModel.wrap(
              Workarea::Reports::ContentSecurityPolicyViolations.new(options),
              options
            )
        end

        def timeline
          @timeline ||= Reports::TimelineViewModel.wrap(
            Workarea::Reports::SalesOverTime.new(
              options.merge(
                starts_at: 3.months.ago,
                group_by: 'day'
              )
            ),
            options
          )
        end
      end
    end
  end
end
