---
title: Use an Existing Workarea App
excerpt: A quick guide to set up a Workarea application.
---

# Use an Existing Workarea Application

This is a quick start guide for getting started on an existing Workarea application. If you're a developer who has a new ticket on an app you just cloned for the first time, this is for you. These steps were written with the following assumptions:

* You have Docker Desktop installed. See [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) to download.
* You have Ruby >= 2.4.0, < 2.7.0 installed. See [https://github.com/rbenv/rbenv#installation](https://github.com/rbenv/rbenv#installation) for instructions.
* You have NodeJS installed. We recommend using [Homebrew](https://brew.sh).
* You have ImageMagick installed. We recommend using [Homebrew](https://brew.sh).
* You have libvips installed. We recommend using [Homebrew](https://brew.sh).
* You have the repository cloned locally.

For more details, see [Prerequisites and Dependencies](/articles/prerequisites-and-dependencies.html).

## Setup an Existing Workarea Application

Follow the steps below to quickly set up an existing Workarea application.

### 1. Check the README

Lots of projects put helpful startup info in their README file. Give it a look and see if there's anything you need to know there. We'll continue this guide assuming nothing relevant or more specific is in there.

```bash
$ cat README.md
```

### 2. Bundle to install gem dependencies

Workarea (and all Rails apps) depend on lots of gems, install the bundle to resolve and install the gems:

```bash
$ bundle install
```

### 3. Start Workarea service dependencies

Workarea relies on a few databases, so there's a task that will start them in Docker containers.
Start Workarea dependencies:

```bash
$ bin/rails workarea:services:up
```

### 5. Seed the database

To do anything useful with Workarea, you'll want some sample data in your database.
The install generator run in step 3 will add Workarea seeds to your `db/seeds.rb` file,
so running Rails seeds will add sample Workarea data.

```bash
$ bin/rails db:seeds
```

For more details on working with seed data, see [Seeds](/articles/seeds.html).

### 6. Start the Rails server

Use the conventional Rails command for starting up the Puma server:

```bash
$ bin/rails server
```

### 7. Open the Application in a Browser

Your Workarea application is ready! Open a browser, and check out `http://localhost:3000`.


## Addendum

### 8. Run Tests

Running tests is a regular part of developing on Workarea. Check out the list of Rails tasks Workarea provides for testing Workarea:

```bash
$ bin/rails -T workarea:test
rails workarea:test              # Run workarea tests (with decorators)
rails workarea:test:admin        # Run workarea admin tests (with decorators)
rails workarea:test:app          # Run all app specific tests
rails workarea:test:core         # Run workarea/core tests (with decorators)
rails workarea:test:decorated    # Run decorated tests
rails workarea:test:performance  # Run workarea performance tests (with decorators)
rails workarea:test:plugins      # Run all installed workarea plugin tests (with decorators)
rails workarea:test:storefront   # Run workarea storefront tests (with decorators)
```

This will run the Workarea test suite (with any [decoration to the tests](/articles/decoration.html) this app adds):

```bash
$ bin/rails workarea:test
```

For more details on Workarea's testing functionality, see [Testing Concepts](/articles/testing-concepts.html).

### 9. Stop the Services

After developing and testing, you may want to stop the services to conserve resources on your machine.

Run the command to stop the services Workarea has started for you:

```bash
$ bin/rails workarea:services:down
```

Note that the volumes these containers used will still be available, and you won't have to seed again the next time you start them.
