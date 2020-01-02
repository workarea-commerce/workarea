---
title: Workarea 3.4.0
excerpt: Upgrade guide for Workarea 3.4.0
---

# Workarea 3.4.0

Upgrade guide for Workarea 3.4.0.

Before we get in to the details, I will assume that you are familiar with using
the _Workarea Upgrade_ tool. This
is a fundamental part for every upgrade, and while we will refer to using it in
this guide, we will not cover specific commands.

## 3.4 Release Notes

The full release notes for v3.4 are available here:
<https://developer.workarea.com/release-notes/workarea-3-4-0.html>

### Some stand-out changes to be aware of

#### Dependency changes

* Requires MongoDB 4.
* Rails 5.2.0
* Supports Ruby 2.6
* Updates jQuery validate to 1.19.0
* Sidekiq Unique Jobs 6
* Active Shipping uses vendored copy
* mongoid-simple-tags uses vendored copy
* Removed dropzones.js from Admin

#### Admin Changes

* All admin dashboards are updated, with additional reports dashboards and views
* Workarea::Analytics deprecated in favor of Workarea::Metrics
* Improved insights content block
* [Improved administration of Favicons](https://developer.workarea.com/articles/favicon-support.html)

#### Storefront Changes

* Now ships with a fully supported, simple, [PWA](https://developers.google.com/web/progressive-web-apps/).
  Including a service worker for offline mode!
* Taxonomy content blocks can now display the starting taxon as a link.
* Better reporting on category and search conversions by adding 'via' tracking
  for all products.
* WORKAREA.breakPoints API made more predictable, removing the possibility of false
  positives.
* No longer suppress analytics events for admin users. This ensures alignment
  between Workarea metrics and 3rd parties.
* Updates Aria attributes and HTML to ensure W3C valid and accessible markup.
* Improved support for Navigation and Search on large touchscreen devices
* Change mobile filters UI to include the entire `#page-aside`

## Important Changes in v3.4

In v3.4 the following changes will need to be made to your application, you
should account for this in your estimate.

### MongoDB v4

In order to support the new Metrics engine, which drives Admin insights and
reporting. Workarea was upgraded to support MongoDB 4.

You’ll need to coordinate v3.4 upgrade with the [Workarea support team](https://support.workarea.com)
due to the MongoDB v4 requirement.

If your application includes a `config/mongoid.yml` file, you may need to rename
the database to align with autoconfiguration. This may involve changing or
removing the mongoid.yml configuration in your project.

#### Installing MongoDB 4 locally

You will need to install MongoDB 4.0 in your local development environment, using
either [the package/installer for your system](https://docs.mongodb.com/manual/installation/#mongodb-community-edition)
or Docker. If you are installing on your system, consider whether you still need
to run MongoDB v3.x for other applications. Internally, the Workarea product team
have found that stopping the MongoDB 3.x service and running MongoDB 4 in a docker
container to be an effective approach. If your development happens entirely within
a Docker environment using `docker-compose` you can update your docker-compose
file to use a MongoDB 4.0 image.

#### Bamboo Updates

To support MongoDB v4 you will need to update your Bamboo configuration to use
scripts.

If your application already has a /script directory for bamboo you can update the
existing scripts using the app template generator (see below) and will not need
to change your bamboo configuration.

If you do not have a /script directory you should create a new branch from master
and add scripts for v3.3.x prior to doing your upgrade. The scripts are included
in the app_template.rb and can be generated using the `app:template` command below.
Once these scripts are merged in to master, QA and Staging branches you should
[create a ticket for Workarea Support](https://jira.tools.weblinc.com/servicedesk/customer/portal/16/create/247)
to update your bamboo build plan. Once your build plan is updated, all feature
branches will need to rebase or merge in the changes from master to include the
scripts directory.

### Generating metrics and insights

To populate your application's Metrics engine, and generate historical insights
you need to run the generator provided in Workarea 3.4

**Note:** Depending on order volume this could take a while to run in production.
You should schedule running this task accordingly.

```bash
bundle exec rails workarea:insights:generate
```

### App Template updates

There were a number of changes to the way new Workarea applications are
configured. To save time finding and fixing those configurations. Or worse,
dealing with bugs due to outdated configurations. You should run this command to
update your application. Be sure to commit your work before running this, and
check to ensure no custom configuration, which you may need to keep, was removed.
**Run this script after you have bumped your application's Workarea version to the latest version of v3.4.x**.

```bash
bundle exec rails generate workarea:install
```

This script will offer the `Ynaqdhm` CLI interface when conflicts are detected.
Using the `d` option to view a diff before deciding whether to accept or reject
a change in each file is recommended.

A few things to note about these configuration changes:

* Puma configuration is now loaded from Workarea core, rather than being specified in the application.
* Adds/Updates the Dockerfile.deploy to support Kubernetes infrastructure.
* Auto configure `force_ssl` in production.rb
* favicon.ico removed to support new favicon implementation
* Adds initializer for basic auth configuration - **you should keep any existing configuration to prevent confusion**
* Adds a placeholder_test.rb - this is for new applications and **should not be
  committed** if you are upgrading an app that already has decorated or added tests

## Update Overridden and Decorated Files

Once you've made the important changes noted above, you're ready for the bulk of
every upgrade. Use the _Workarea Upgrade_ tool
to generate a diff, then work through the changes in each file. You will need to
use your judgement to decide which changes to make, and which changes are not necessary.

## Congratulations

This should have gotten you from v3.3 to v3.4! If you're stuck, or have further
questions, please [contact Workarea support](https://support.workarea.com).

Feel free to include members of the Workarea Support team on your pull request.
