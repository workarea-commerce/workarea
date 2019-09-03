Workarea Commerce Platform
================================================================================
[![Build Status](https://travis-ci.com/workarea-commerce/workarea.svg?token=YjqtGLgnbrDJ77Kqw1nV&branch=master)](https://travis-ci.com/workarea-commerce/workarea)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

[Workarea](https://www.workarea.com) is an enterprise-grade commerce platform written in [Ruby on Rails](https://rubyonrails.org). It uses [MongoDB](https://www.mongodb.com), [Elasticsearch](https://www.elastic.co/products/elasticsearch), and [Redis](https://redis.io). Workarea also uses a whole lot of gems you can see in [our gemspec](https://github.com/weblinc/workarea/blob/master/core/workarea-core.gemspec).

[Workarea Commerce Cloud](https://www.workarea.com/pages/commerce-cloud)
[Documentation](https://developer.workarea.com)
[Demo](https://github.com/workarea-commerce/workarea#demo)
[Getting Started](https://github.com/workarea-commerce/workarea#getting-started)
[Plugins](https://github.com/workarea-commerce/workarea#plugins)
[Deploying](https://github.com/workarea-commerce/workarea#deploying)
[Contributing](https://github.com/workarea-commerce/workarea#contributing)
[Slack](https://www.workarea.com/slack)

![Workarea Screenshot](https://raw.githubusercontent.com/workarea-commerce/workarea/master/docs/source/images/readme-hero.png)

Features
--------------------------------------------------------------------------------
Workarea combines commerce, content, search, and insights into a unified platform to enable merchants to move faster and work smarter. Out-of-the-box features include:

**Storefront**
* Mobile-first frontend
* Localization support
* First-class SEO
* Built-in analytics
* Cart and checkout
* Customer accounts
* Discounts
* Basic taxes
* Shipping services

**Content**
* Responsive CMS
* Asset management
* Localized content
* Intelligent merchandising
* Content-based navigation

**Search**
* Product search
* Search-driven categories
* Filtering and sorting
* Search merchandising
* Results tuning
* Advanced reporting

**Insights**
* Robust dashboards
* Sales reports
* Trending reports
* Search reports
* Advanced insights

**Admin**
* Site planning and automation
* Workflows for common tasks
* Inline insights
* Search-first administration
* Commenting
* Audit logs for changes


Demo
--------------------------------------------------------------------------------

You can run a demo version of workarea by running the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/workarea-commerce/workarea/master/demo/install | bash
```

It requires you have Docker installed and running. Once complete, you can visit `http://localhost:3000` to view your app.

The seed data provides an admin user with an email/password of `user@workarea.com/w0rkArea!`.

See the [README](demo/README.md) in the `demo` directory for more information.

For more information on usage and troubleshooting, see the [workarea-demo](https://github.com/workarea-commerce/workarea-demo) page.

Getting Started
--------------------------------------------------------------------------------
We'll assume you have [Docker desktop](https://www.docker.com/products/docker-desktop) and [Ruby >= 2.4.0, < 2.7.0](https://github.com/rbenv/rbenv#installation) installed.

1. Add the `workarea` gem to the `Gemfile` in your Rails 5.2 app:

        gem 'workarea', '~> 3.4.6'

2. Install the gems:

        $ bundle install

3. Start the workarea services (uses Docker):

        $ bin/rails workarea:services:up

4. Run the Workarea Rails generator:

        $ bin/rails generate workarea:install

   This generator will mount the Workarea engines in `config/routes.rb`, and add Workarea seeds to `db/seeds.rb`.

5. Run the database seeds:

        $ bin/rails db:seed

5. Run the Rails server:

        $ bin/rails server

6. Visit `http://localhost:3000` in a browser and you'll see your Workarea storefront.

For more information on getting started, see the [quick start](https://developer.workarea.com/articles/create-a-new-app.html) guide.


Plugins
--------------------------------------------------------------------------------
Workarea extends functionality with a library of plugins. These plugins add everything from additional content blocks, to wish lists, to payment gateway integrations and more. Here are some of the most popular plugins:

| Plugin | Description |
| --- | --- |
| [API](https://github.com/workarea-commerce/workarea-api) | Provides APIs for storefront and admin |
| [Blog](https://github.com/workarea-commerce/workarea-blog) | Integrated blogging |
| [Reviews](https://github.com/workarea-commerce/workarea-reviews) | Adds product reviews |
| [Google Analytics](https://github.com/workarea-commerce/workarea-google-analytics) | Integrates GA with Workarea's analytics |
| [Paypal](https://github.com/workarea-commerce/workarea-paypal) | Adds Paypal checkout |
| [Wish Lists](https://github.com/workarea-commerce/workarea-wish-lists) | Adds customer wish lists |
| [Sitemaps](https://github.com/workarea-commerce/workarea-sitemaps) | Autogenerating sitemaps |
| [Share](https://github.com/workarea-commerce/workarea-share) | Adds page sharing via social media or email |
| [Google Tag Manager](https://github.com/workarea-commerce/workarea-tag-manager) | Adds [Google Tag Manager](https://marketingplatform.google.com/about/tag-manager/) |
| [Package Products](https://github.com/workarea-commerce/workarea-package-products) | Allows displaying products as a group in browse and details pages |
| [Gift Cards](https://github.com/workarea-commerce/workarea-gift-cards) | Adds Workarea-native digital gift cards |

Deploying
--------------------------------------------------------------------------------
Workarea is fairly complex application to host, we recommend our [Commerce Cloud](https://www.workarea.com/pages/commerce-cloud) hosting.

If you'd like to host on your own, we have some documentation to help:

* [Required infrastructure](https://developer.workarea.com/articles/infrastructure.html)
* [Configuring Workarea for hosting](https://developer.workarea.com/articles/configuration-for-hosting.html)


Contributing
--------------------------------------------------------------------------------
All contributors in any way are expected to follow the [code of conduct](https://github.com/workarea-commerce/workarea/blob/master/CODE_OF_CONDUCT.md).

### Looking for how to contribute code?
We encourage you to contribute to Workarea! Check out our [articles on contribution](https://developer.workarea.com/articles/contribute-code.html) on [https://developer.workarea.com](https://developer.workarea.com).

### Looking for how to submit a bug?
Please check out our [article on how to submit a bug](https://developer.workarea.com/articles/report-a-bug.html) for how to proceed

### Looking for how to report a security vulnerability?
Please check out our [security policy](https://developer.workarea.com/articles/security-policy.html) for how to proceed.


License
--------------------------------------------------------------------------------
Workarea Commerce Platform is released under the [Business Software License](https://github.com/workarea-commerce/workarea/blob/master/LICENSE)
