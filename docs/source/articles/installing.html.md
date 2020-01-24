---
title: Installing
created_at: 2019/05/29
excerpt: A guide on the Workarea install script.
---

# Installing

Workarea is a large Rails engine that requires a few things out of a Rails app it's installed into. This guide will walk you through the details of running `bin/rails generate workarea:install` so you know what changes are being made and why.

### `application.rb`

First, this will require the Workarea gems in your `config/application.rb` file. This is done to ensure Workarea can control the environment your application is run in for the purposes of testing and rake tasks.

### `routes.rb`

The install generator will mount the three main engines that workarea is built on within your `config/routes.rb` file.

```ruby
Rails.application.routes.draw do
  mount Workarea::Core::Engine => '/'
  mount Workarea::Admin::Engine => '/admin', as: 'admin'
  mount Workarea::Storefront::Engine => '/', as: 'storefront'
end
```

### `workarea.rb`

An initializer will be created at `config/initializers/workarea.rb`. This serves that the main location for modifying configuration for Workarea. The generator will add some default information based on the name of your application such as `site_name`, `host`, `email_from`, and `email_to`. These serve as critical pieces of information for Workarea to know in order to start the application. Be sure to address the `TODO`s in the file and add the correct production information before deploying to a live environment.

### `development.rb`

Workarea relies on [Sidekiq](https://github.com/mperham/sidekiq) for running background jobs. For development, the install generator will add the following line of code to your `config/environments/development.rb` to alleviate the need for sidekiq to be running while in development.

```ruby
require 'sidekiq/testing/inline'
```

This tells sidekiq to run workers in process while working locally.

### `test_helper.rb`

Workarea provides robust [testing configuration](/articles/testing-concepts.html) for consistent and easy testing. The install generator will add `require workarea/test_help.rb` to your existing `test/test_helper.rb` file.

### `favicon.ico`

Workarea provides [favicon support](/articles/favicon-support.html) through content assets within the admin UI. As a result, the install generator removes the `public/favicon.ico` file generated with a new rails application so that it does not interfere with that functionality.

### `seeds.rb`

Workarea provides a large set of [seed data](/articles/seeds.html) to get your application started. The install generator adds the `db/seeds.rb` file so that you can run seeds like any other rails application.
