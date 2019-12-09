---
title: Integrating with Other Software
excerpt: Overview of a developer's options for integrating Workarea with third-party software.
---

# Integrating with Other Software

Integrating with other systems is one of the toughest parts of a large-scale ecommerce site build. Whether it's an ESP, a crusty old mainframe system, or a homegrown CRM, Workarea has many options to help. Picking between these depends on the needs, capabilities, and people of the system you're integrating with, so below you'll find the major options outlined.

## Plugins

The easiest option for integration is a plugin already built by the Workarea team or the community. A typical install means adding the gem to the project's `Gemfile` and configuring some credentials. You'll want to check the README on the plugin for details.

To see a list of available open-source integration plugins, check out the Workarea [Github repositories](https://github.com/workarea-commerce). For more info on how plugins work (including how to write your own), see the [plugins overview](/articles/plugins-overview.html).

## API

The admin API offers the minimum amount of work on the Workarea side for the integration. Through the API, you can get and/or update all the major resources in the Workarea system. This is a great option if you have the cooperation of developers on the other end - they can write calls to the API as needed.

See the [API overview](/articles/api-overview.html) for more info, or jump into the deep end with [the API documentation](https://demo.workarea.com/api/docs).

## Webhooks

Webhooks are an option where Workarea will call out to a provided URL with a payload when a particular event (e.g. an order gets placed or a customer account is created) occurs. The payload will contain data related to the event. This is nearer to real-time than the other out-of-the-box options. Like API integration, choosing webhooks is good when you have the cooperation of developers on the other end. Someone will have to setup the desired events/URLs in the admin.

See the [Webhooks plugin](https://github.com/workarea-commerce/workarea-webhooks) for more info.

## Scheduled Data Files

Scheduling data file transfers is a more old-fashioned, but still automated option for integration. Great for overnight batched integrations with older systems that will need to ingest CSV files and the like. An administrator can specify what they want to import or export, how often and when. It supports S3, SFTP, or local file system as data stores.

See the [Data File Scheduling plugin](https://github.com/workarea-commerce/workarea-data-file-scheduling) for more info.

## Admin Import/Export

All the major index pages in the admin (people, orders, products, etc) are available to import and export in multiple formats from the admin interface. The links appear in the workflow bar in the bottom left of those screens. The downside to this option is that everything must be completely manual.

![Import/Export Screenshot](/images/import-export-screenshot.png)

## Custom Code

The most manual, developer-involved option for integration with third party software is to write the code manually. Obviously this the most expensive/time-consuming of the options. The advantage however, is the integration can be built completely bespoke to the merchant's needs.


### Scheduled Workers

Scheduled workers are good for working in batches, for example exporting orders every hour. Workarea includes a gem for scheduling Sidekiq jobs called [sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron). As a super admin, you'll be able to monitor the status of these jobs in the Sidekiq admin at `/admin/sidekiq/cron`.

See the [Sidekiq Cron Job section](/articles/workers.html#sidekiq-cron-job) of the [workers article](/articles/workers.html).

### Callbacks Workers

Another good asynchronous option is callbacks workers. Workarea adds an extension to Sidekiq worker functionality to allow automatically enqueueing Sidekiq workers based on customizable callbacks in models. This is good for doing individual calls to external systems as the events in Workarea happen. For example, when an email signup is created, run a Sidekiq worker to add that email to an ESP.

See the [Sidekiq Callbacks section](/articles/workers.html#sidekiq-callbacks) of the [workers article](/articles/workers.html).

### Inline

This is least preferred option of all for this task, due to its fragility. It puts the stability of Workarea at the mercy of the other system. The basic idea is adding in the calls to the external software inline with the Workarea code. Examples would be putting calls to fraud checks in checkout controllers, or "real-time" inventory calls from product detail pages. The pattern you'll use to do this is called "decoration", you can read more about it in [our decorators article](/articles/decoration.html).
