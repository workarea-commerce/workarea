---
title: Create a New Workarea App
excerpt: A quick guide to set up a Workarea application.
---

# Create a New Workarea App

This is a quick start guide for getting started on a brand new Workarea application. If you're new to developing on Workarea this is a great place to start.

__If you experience a problem while following these instructions, get help on the [Workarea Community Slack](https://www.workarea.com/slack) or open an [issue on GitHub](https://github.com/workarea-commerce/workarea/issues).__

After reviewing the [assumptions](#assumptions), complete the following steps to create a new Workarea application and open it in your browser:

1. [Create a Rails application](#create-a-rails-application)
2. [Add the Workarea gem](#add-the-workarea-gem)
3. [Start Workarea service dependencies](#start-workarea-service-dependencies)
4. [Install Workarea into the Rails application](#install-workarea-into-the-rails-application)
5. [Seed the database](#seed-the-database)
6. [Start the Rails server](#start-the-rails-server)
7. [Open the application in a browser](#open-the-application-in-a-browser)

Then, you may want to [run tests](#run-tests) and [stop the services](#stop-the-services).

## Assumptions

The steps that follow assume the following:

* You have Docker Desktop installed. See [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) to download.
* You have Ruby >= 2.4.0, < 2.7.0 installed. See [https://github.com/rbenv/rbenv#installation](https://github.com/rbenv/rbenv#installation) for instructions.
* You have NodeJS installed. We recommend using [Homebrew](https://brew.sh).
* You have ImageMagick installed. We recommend using [Homebrew](https://brew.sh).
* You have libvips installed. We recommend using [Homebrew](https://brew.sh).

For more details, see [Prerequisites and Dependencies](/articles/prerequisites-and-dependencies.html).

## TL;DR Video Walkthrough

<iframe src="https://player.vimeo.com/video/370085475" width="640" height="360" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>
<p><a href="https://vimeo.com/370085475">Workarea Dev Quickstart</a> from <a href="https://vimeo.com/workarea">Workarea Commerce Platform</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

## Create a Rails application

This creates a barebones Rails app for Workarea to install into:

```bash
mkdir my-store && cd my-store
echo "source 'https://rubygems.org'" > Gemfile
echo "gem 'rails'" >> Gemfile
bundle install
bundle exec rails new ./ --force \
--skip-spring \
--skip-active-record \
--skip-action-cable \
--skip-puma \
--skip-coffee \
--skip-turbolinks \
--skip-bootsnap \
--skip-yarn \
--skip-bundle \
--skip-webpack-install
```

## Add the Workarea gem

This adds the Workarea base gem to the project and updates dependencies:

```bash
echo "gem 'workarea'" >> Gemfile
bundle update
```

## Start Workarea service dependencies

Workarea relies on a few databases, so there's a task that will start them in Docker containers.
Start Workarea dependencies:

```bash
bin/rails workarea:services:up
```

## Install Workarea into the Rails application

Workarea ships with an installer generator that will configure the application:

```bash
bin/rails generate workarea:install
```

For more details on what this generator does, see [Installing Workarea](/articles/installing.html).

## Seed the database

To do anything useful with Workarea, you'll want some sample data in your database.
The install generator run in step 3 will add Workarea seeds to your `db/seeds.rb` file,
so running Rails seeds will add sample Workarea data.

```bash
bin/rails db:seed
```

For more details on working with seed data, see [Seeds](/articles/seeds.html).

## Start the Rails server

Use the conventional Rails command for starting up the Puma server:

```bash
bin/rails server
```

## Open the application in a browser

Your Workarea application is ready! Open a browser, and check out `http://localhost:3000`.

## Run tests

Running tests is a regular part of developing on Workarea. Check out the list of Rails tasks Workarea provides for testing Workarea:

```bash
bin/rails -T workarea:test
```

Try one of the test runners listed in that output. For example, this will run the Workarea test suite:

```bash
bin/rails workarea:test
```

For more details on Workarea's testing functionality, see [Testing Concepts](/articles/testing-concepts.html).

## Stop the services

After developing and testing, you may want to stop the services to conserve resources on your machine.

Run the command to stop the services Workarea has started for you:

```bash
bin/rails workarea:services:down
```

Note that the volumes these containers used will still be available, and you won't have to seed again the next time you start them.
