---
title: Add a Report
excerpt: This page will guide you through a step-by-step process of creating a new report within the Workarea admin.
---

# Add a Report

Workarea provides a number of useful reports that can be used to analyze the data collected via [metrics](/articles/add-metrics.html) or any other collection in the database. Though extensive, it is possible a retailer may have the need for a report not provided out of the box. Adding a new report includes:

* A class to generate the report results
* A view model to help format the results
* A route/controller action
* Views to display the results on both the reports dashboard and the full reports page.

## Create a report class

Reports are typically not much more than a class the performs a [MongoDB aggregation](https://docs.mongodb.com/manual/aggregation/) on an existing collection. A report is represented by a class in `app/queries` that follows a structure like this:

```ruby
# app/queries/workarea/reports/custom.rb
module Workarea
  module Reports
    class Custom
      include Report

      self.reporting_class = Metrics::ProductByDay
      self.sort_fields = %w(revenue units_sold)

      def aggregation
        [
          # aggregation stages
        ]
      end
    end
  end
end
```

Each report will `include Report`, which is a module that provides shared behavior of reporting date filtering helpers, sorting, result limits, and the logic for generating the results from the aggregation. `reporting_class` tells the `Report` module which collection to aggregate on, and `sort_fields` defines which fields from the resulting documents can be used to sort the documents. The `#aggregation` method defines the aggregation to run, and must return an array of the mongo aggregation stages.

The `reporting_class` can be any model representing a Mongo collection, but typically will be a `Metrics` collection. If a new report requires data that does not exist, you can [add new metrics](/articles/add-metrics.html) along with the new report.

It is encouraged that you write a unit test for your report to ensure it is generating results as expected.

## Create a view model

Each report is expected to have corresponding view model in the admin. These view models serve to enrich the result set with more user-friendly information like adding the product model to each document instead of just displaying a product id.

```ruby
# app/view_models/workarea/admin/reports/custom_view_model.rb
module Workarea
  module Admin
    module Reports
      class CustomViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            product = products.detect { |p| p.id == result['_id'] }
            OpenStruct.new({ product: product }.merge(result))
          end
        end

        def products
          @products ||= Catalog::Product.any_in(
            id: model.results.map { |r| r['_id'] }
          ).to_a
        end
      end
    end
  end
end
```

`OpenStruct` is used to provide a more developer-friendly API to the result sets from reports.

## Decorate `Dashboards::ReportsViewModel`

To begin making this report visible to an admin user, a method on the `Admin::Dashboards::ReportsViewModel` is required so that the new report's results are available to display on the reports dashboard.

```ruby
# app/view_models/workarea/admin/dashboards/reports_view_model.decorator
module Workarea
  decorate Admin::Dashboards::ReportsViewModel, with: :project_name do
    def custom
      @custom ||= Admin::Reports::CustomViewModel.wrap(
        Workarea::Reports::Custom.new(options),
        options
      )
    end
  end
end

```

## Add route and controller action

Each report requires its own route and controller action to be defined.

```ruby
# config/routes.rb
Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resource :report, only: [] do
      get :custom
    end
  end
end
```

Decorate `Admin::ReportsController` to add the new report's action:

```ruby
# app/controllers/workarea/admin/reports_controller.decorator
module Workarea
  decorate Admin::ReportsController, with: :project_name do
    def custom
      @report = Admin::Reports::CustomViewModel.wrap(
        Workarea::Reports::Custom.new(params),
        view_model_options
      )
    end
  end
end
```

## Add view partials for reports dashboard

To display the new report on the report's dashboard, a partial view needs to be created and appended to the dashboard view.

```ruby
# app/views/workarea/admin/dashboards/_custom_report.html.haml
.grid__cell
  .card{ class: card_classes(:custom_report, local_assigns[:active]) }
    = link_to custom_report_path, class: 'card__header' do
      %span.card__header-text= t('workarea.admin.reports.custom.title')
      = inline_svg 'workarea/admin/icons/insights.svg', class: 'card__icon'

    .card__body
      .card__centered-content
        %table
          %tbody
            - dashboard.custom.results.take(4).each do |result|
              %tr
                %td= result.product.present? ? result.product.name : result._id
                %td.align-right= number_to_currency(result.revenue)

        = link_to custom_report_path, class: 'card__button' do
          %span.button.button--small= t('workarea.admin.dashboards.reports.view_full_report')

```

```ruby
# config/initializers/appends.rb
Workarea.append_partials(
  'admin.reports_dashboard',
  'workarea/admin/dashboards/custom_card'
)
```

## Add view for report

The last thing that needs to be added is the view for the report itself, which contains some amount of boilerplate to offer the user exporting of the data and provide helpful information and date filtering. Most reports are a table of the results that offers sorting by clicking on column headers. The logic for all common behavior is extracted and available to use in your report views.

```ruby
# app/views/workarea/admin/reports/custom.html.haml
- @page_title = t('workarea.admin.reports.custom.title')

.view
  .view__header
    .view__heading
      = link_to "↑ #{t('workarea.admin.reports.all_reports')}", reports_dashboards_path
      %h1.heading.heading--no-margin= t('workarea.admin.reports.custom.title')
      %p= t('workarea.admin.reports.reference_link_html', path: reference_report_path)

  .view__container
    .browsing-controls.browsing-controls--with-divider.browsing-controls--center.browsing-controls--filters-displayed
      = form_tag custom_report_path, method: 'get', class: 'browsing-controls__form' do
        = render 'workarea/admin/shared/date_selector', starts_at: @report.starts_at, ends_at: @report.ends_at

      .browsing-controls__count
        = render_reports_results_message(@report)
        = render 'workarea/admin/reports/export', report: @report

    %table
      %thead
        %tr
          %th= t('workarea.admin.fields.product')
          %th.align-center= link_to_reports_sorting t('workarea.admin.fields.units_sold'), report: @report, sort_by: 'units_sold'
          %th.align-right= link_to_reports_sorting t('workarea.admin.fields.revenue'), report: @report, sort_by: 'revenue'
      %tbody
        - @report.results.each do |result|
          %tr
            %td
              - if result.product.present?
                = link_to result.product.name, catalog_product_path(result.product)
              - else
                = result._id
            %td.align-center= number_with_delimiter(result.units_sold)
            %td.align-right= number_to_currency(result.revenue)

```

It is encouraged that you write a system test to ensure that your report renders as expected and without errors.
