---
title: Overview
excerpt: An overview of what Workarea is, how it's distributed, and its major technologies.
---

# Overview

Workarea is an open-source, enterprise-grade commerce platform. The platform and many of its plugins are maintained by Workarea. The rest of the Workarea community maintain the majority of Workarea's plugins and also contribute directly to the platform. Workarea Commerce Cloud is a subscription service offered by the [Workarea](https://www.workarea.com) company, which includes extended functionality and cloud-based hosting.

## Built with

### Ruby

Workarea is written in Ruby, and is built on the [Ruby on Rails](https://rubyonrails.org) framework. As such, it's distributed as a gem via [RubyGems](http://guides.rubygems.org/). Workarea and it's plugins are [Rails' engines](https://guides.rubyonrails.org/engines.html) that get mounted inside a host Rails application. Workarea also relies on [Sidekiq](https://sidekiq.org) for processing background work.

### Databases

#### MongoDB

[MongoDB](https://www.mongodb.com) serves as the canonical, database-of-record in Workarea. Its flexible, document-oriented data model is a good fit for diverse catalogs offered by retailers and fits well with our plugin model, where the schema can be managed in the application code.

#### Elasticsearch

[Elasticsearch](https://www.elastic.co/products/elasticsearch) drives all the important listing and browsing done in Workarea. This includes storefront search, product recommendations, category browsing, admin indexes, and more. Its robust querying makes it a perfect fit for all the searching requirements a large ecommerce system has.

#### Redis

[Redis](https://redis.io) is Workarea's Swiss army knife of databases. It stores the Sidekiq job queue, provides storage for recommendations, serves as the Rails cache, and more.

## Customization

Workarea is designed to be customized to work for merchants with different needs. The four primary ways of customizing Workarea's behaviors are [configuration](/articles/configuration.html), [plugins](/articles/plugins-overview.html), [decoration](/articles/decoration.html), and Rails' overrides system ([overriding](/articles/overriding.html)).

## Testing

Workarea inherits the Rails' community's ethic of testing. In this spirit, Workarea distributes its test suite as runnable and customizable, just like any application code using decoration techniques. This helps implementers of Workarea to ensure their customizations don't break Workarea out-of-the-box functionality and helps with upgrades to new versions. [Read more on testing.](/articles/testing-concepts.html)

## How do I get started?

You have two options for jumping in with Workarea.

1. Try out a user-facing demo, using [instructions from our README](https://github.com/workarea-commerce/workarea#demo)
2. [Create a new app](/articles/create-a-new-app.html) and start coding
