---
title: Infrastructure
excerpt: An overview of the required pieces of infrastructure for hosting Workarea.
---

# Infrastructure

This will be a brief overview of what you'll need to host a Workarea app on your own. Workarea is a hefty application which can be complex to run efficiently, so we recommend our [Workarea Commerce Cloud hosting](https://www.workarea.com/pages/commerce-cloud) for merchants who want to focus on their unique business problems.

## Application

### Web

If you're a subscriber to the Workarea Commerce Cloud, you should use the `workarea-commerce-cloud` plugin for hosting configuration. Otherwise, we recommend a standard Rails Puma configuration.

### Sidekiq

Workarea depends on [Sidekiq](https://sidekiq.org) for performing background work, so you'll need to have a Sidekiq daemon running along with the application server. Workarea will automatically configure Sidekiq based on its own configuration.

## Databases

### MongoDB

Workarea uses on [MongoDB](https://www.mongodb.com), so you'll need a production-grade replica set. Currently, the latest version of Workarea supports MongoDB v4.0.x.

### Elasticsearch

Workarea uses [Elasticsearch](https://www.elastic.co/products/elasticsearch) for large portions of functionality. You'll want a production-grade cluster running version v5.6.x.

### Redis

Workarea uses [Redis](https://redis.io) for the Sidekiq queue, cache, Rack::Attack, and more. Note that while only one instance of Redis is _required_, we recommend running two. The first would be for persistent data like the Sidekiq queue or recommendations. The second is for ephemeral data like cache.

## Miscellaneous

### Assets

Currently, Workarea depends on [Amazon's S3](https://aws.amazon.com/s3/) to back its asset storage. You'll need at least one bucket setup to run Workarea. An optional second (called the "integration" bucket in the code) can be configured for integrating with other systems, like flat-file exports, image imports, etc.

### Geolocation

Workarea provides a number of geography-based features. For these features to function, you have two options. The first (very slow) way is to configure the [Geocoder gem](https://github.com/alexreisner/geocoder) that Workarea uses to look up request location by IP address. The second, preferred way is to integrate an upstream proxy like [nginx](http://nginx.org) to lookup geography data based on IP address and add headers, which the Workarea application will read. See [the ngx_http_geoip_module](http://nginx.org/en/docs/http/ngx_http_geoip_module.html) for an example.

### Compliance

This is just dropping you a note that the Workarea application is written to be compliant with PCI-DSS requirements. Workarea Commerce Cloud hosting provides a complete top-to-bottom certified, tier 1, PCI-DSS environment. This is recommended for all merchants.
