---
title: Add Metrics
excerpt: This page will guide you through a step-by-step process of adding new metrics data for insights and reports.
---

# Add Metrics

Workarea tracks activity of the site through a mechanism called Metrics. Information like catalog activity and sales, discount usage, search data, and more are aggregated on a daily basis and sometimes further aggregated weekly. This data collection allows for the creation of most of the reports and insights within the Workarea admin.

While Workarea provides metrics on critical data points within the system, it is possible a more specialized metric might become desirable in order to provide retailers with insights or reports unique to their business.

Metrics consist of a Mongoid model and are populated through any number mechanism including analytics adapters and data saved after an order is placed. This guide will walk through the creation of the Metric model, and show a short code example of how you could integrate tracking of the data.

# Create a Metric model

The first step is establishing the model that will represent the collection within the database where the data is stored. In this scenario, a retailer may have downloadable files on their site and want to track how often they are downloaded.

```ruby
# app/models/workarea/metrics/downloads_by_day.rb
module Workarea
  module Metrics
    class DownloadsByDay
      include ByDay

      field :file_id, type: String
      field :clicks, type: Integer, default: 0
    end
  end
end
```

A Metric intended for daily data collecting should `include ByDay`, which is module that provides common fields and methods that all daily tracked metrics require to function as the system expects. The most important aspects are the `reporting_on` field which is used to track which day the day represents, and the `#inc` method which is the mechanism by which data for a specific day can easily be added to the document.

## Integrate tracking

For the purpose of this scenario, let's assume there is an analytics event setup to fire when a user clicks a download link and an analytics adapter that makes a XHR request to the server with the ID of the file being downloaded. [See the analytics overview](/articles/analytics-overview.html) for information on how analytics are integration into Workarea.

In this example, a controller action can be setup to increment the `clicks` field on the appropriate document in the `Workarea::Metrics::DownloadsByDay` collection.

```ruby
# app/controllers/workarea/storefront/download_analytics_controller.rb
module Workarea
  module Storefront
    class DownloadAnalyticsController < ApplicationController
      def click
        Metrics::DownloadsByDay.inc(
          key: { file_id: params[:file_id] },
          clicks: 1
        )
      end
    end
  end
end
```

## Using metrics data

Once the model has been created, and the mechanism by which it is populated is integrated into the site, that data can be aggregated and analyzed for insights and for [new reports](/articles/add-a-report.html) offered within the Workarea admin.
