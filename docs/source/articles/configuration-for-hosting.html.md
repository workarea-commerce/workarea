---
title: Configuration for Hosting
excerpt: How to configure Workarea for hosting in practice.
---

# Configuration for Hosting

Here's what you'll need to configure Workarea for hosting. It'll outline commonly set configurations and why. To learn more about Workarea infrastructure configuration, check out the code here: [https://github.com/workarea-commerce/workarea/tree/master/core/lib/workarea/configuration](https://github.com/workarea-commerce/workarea/tree/master/core/lib/workarea/configuration).

## Application

### Web

If you're a subscriber to the Workarea Commerce Cloud, you should use the [`workarea-commerce-cloud`](https://github.com/workarea-commerce/workarea-commerce-cloud) plugin for hosting configuration. Otherwise, we recommend a standard Rails Puma configuration.

### Sidekiq

Workarea will automatically configure Sidekiq based on the other Workarea configuration (like Redis).

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_SIDEKIQ_CONCURRENCY` | Dynamic | Based on number of processes |
| `WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT` | `5` |

_Note:_ Workarea will not try to configure Sidekiq if `config/sidekiq.yml` or `config/sidekiq.yml.erb` are present.

## Databases

### MongoDB

Workarea automatically configures Mongoid for you with the recommended settings. No further action is required. However, settings provided in `config/mongoid.yml` will override the default Workarea configuration. Doing this is discouraged.

Workarea uses two different instances of `Mongoid::Client`, one for primary application use, and one specifically for metrics collection. This is done to allow sharding metrics/reporting from standard application use.

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_MONGOID_HOST_0` | `localhost:27017` | increment `0` for each host |
| `WORKAREA_MONGOID_OPTIONS` | `{}` | JSON-serialized [options for Mongoid](https://docs.mongodb.com/mongoid/current/tutorials/mongoid-installation/#anatomy-of-a-mongoid-config) |
| `WORKAREA_MONGOID_METRICS_HOST_0` | `localhost:27017` | increment `0` for each host |
| `WORKAREA_MONGOID_METRICS_OPTIONS` | `{}` | JSON-serialized [options for Mongoid](https://docs.mongodb.com/mongoid/current/tutorials/mongoid-installation/#anatomy-of-a-mongoid-config) |

You can configure hosts using `WORKAREA_MONGOID_HOST_*` environment variables. You can add as many hosts as desired, just be sure to end the environment variable names with digits, e.g. `WORKAREA_MONGOID_HOST_0`, `WORKAREA_MONGOID_HOST_1`, `WORKAREA_MONGOID_HOST_2`, etc.

### Elasticsearch

You can set an arbitrary number of Elasticsearch hosts for Workarea to use, or simply specify one (perhaps behind a load balancer).

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_ELASTICSEARCH_URL_0` | `localhost:9200` | increment `0` for each host |
| `WORKAREA_ELASTICSEARCH_URL` | `localhost:9200` | used if the digit-trailing vars are blank |

You can configure hosts using `WORKAREA_ELASTICSEARCH_URL_*` environment variables. You can add as many hosts as desired, just be sure to end the environment variable names with digits, e.g. `WORKAREA_ELASTICSEARCH_URL_0`, `WORKAREA_ELASTICSEARCH_URL_1`, `WORKAREA_ELASTICSEARCH_URL_2`, etc.

### Redis

While only one instance of Redis is _required_ to run Workarea, you can run two for distributing load. The first would be for persistent data like the Sidekiq queue or recommendations. The second is for ephemeral data like cache.

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_REDIS_HOST` | `localhost` | host for persistent Redis |
| `WORKAREA_REDIS_PORT` | `6379` | port for persistent Redis |
| `WORKAREA_REDIS_DB` | `0` | database for persistent Redis |
| `WORKAREA_REDIS_CACHE_HOST` | `localhost` | host for ephemeral Redis |
| `WORKAREA_REDIS_CACHE_PORT` | `6379` | port for ephemeral Redis |
| `WORKAREA_REDIS_CACHE_DB` | `0` | database for ephemeral Redis |

## Miscellaneous

### Assets

You'll need at least one S3 bucket setup to run Workarea. An optional second (called the "integration" bucket in the code) can be configured for integrating with other systems, like flat-file exports, image imports, etc.

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_S3_REGION` | `us-east-1` | - |
| `WORKAREA_S3_ACCESS_KEY_ID` | | if this is blank _and_ the secret access key is blank, Workarea will use the IAM profile |
| `WORKAREA_S3_SECRET_ACCESS_KEY` | | if this is blank _and_ the access key ID is blank, Workarea will use the IAM profile |
| `WORKAREA_S3_BUCKET_NAME` | | - |
| `WORKAREA_S3_INTEGRATION_REGION` | | (optional) |
| `WORKAREA_S3_INTEGRATION_ACCESS_KEY_ID` | | (optional) |
| `WORKAREA_S3_INTEGRATION_SECRET_ACCESS_KEY` | | (optional) |
| `WORKAREA_S3_INTEGRATION_BUCKET_NAME` | | (optional) |

### Asset Host

Workarea ships with support for the asset host as an environment variable. This sets the Rails configurations to this value.

| Name | Default | Notes |
|---|---|---|
| `WORKAREA_ASSET_HOST` | | set this to your CDN |
