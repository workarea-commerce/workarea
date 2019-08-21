---
title: Workarea 3.3.25
excerpt: Patch release notes for Workarea 3.3.25.
---

# Workarea 3.3.25

Patch release notes for Workarea 3.3.25.

## Display Active State In Mobile Navigation

Apply the `--selected` modifier to the `mobile-nav__link` element in
mobile. This was previously not being applied if the link had been
selected, and thus the active state was not displaying on mobile.

### Issues

- [ECOMMERCE-5691](https://jira.tools.weblinc.com/browse/ECOMMERCE-5691)

### Pull Requests

- [3965](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3965/overview)

## Fix Redemption of Redundant Promo Codes

When a user adds multiple promo codes that belong to the same discount
to an order, only mark the first one as being used so other users can
take advantage of the other promo codes. Previously, all promo codes
were being marked as redeemed in the backend, preventing their use by
others.

### Issues

- [ECOMMERCE-5745](https://jira.tools.weblinc.com/browse/ECOMMERCE-5745)

### Pull Requests

- [3925](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3925/overview)

## Run Dependent Services in Docker Containers

Due to the complicated nature of Dockerized Workarea environments,
especially surrounding system tests, Workarea now provides an
alternative solution to starting the correct background services (at the
correct versions) that are necessary for Workarea apps to function, such
as Elasticsearch, MongoDB, and Redis. Two Rake tasks,
`workarea:services:up` and `workarea:services:down`, will run [Docker
Compose](https://docs.docker.com/compose/) with a configuration file
that is located within the Workarea gem itself. This configuration
uses the correct versions of each dependent service for the
version of Workarea you're using. Workarea v3.4 applications, for
example, will use MongoDB 4.x, while Workarea v3.3 and below use MongoDB
3.x.

When you start working on a Workarea application, run the following
command to start your dependent services:

    bin/rails workarea:services:up

And when you're done working, run the following command to stop them:

    bin/rails workarea:services:down

Doing this between each project keeps the databases in separate
containers and volumes, the latter of which are persisted even when
containers are down, so you won't lose your development data. (Just
remember to delete your volumes when upgrading from v3.3 to v3.4!) The
Docker Compose project name will be the name of the application you are
currently working on. Since this matches the root directory of the
application, you can run `docker-compose` commands just like you
normally would in a Dockerized application, except you no longer have to
jump through the extra hoops of working in containers when developing on
your application.

### Issues

- [ECOMMERCE-6789](https://jira.tools.weblinc.com/browse/ECOMMERCE-6789)

### Pull Requests

- [3970](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3970/overview)

## Update Checkbox Styles in Admin to avoid test failure

To allow the most recent version of Chrome to click on checkboxes in the
`Admin::BulkActionsSystemTest`, they have been styled using [the
"checkbox hack"](https://css-tricks.com/the-checkbox-hack/). This should
help with build errors on CI servers as well as locally in system tests.

### Issues

- [ECOMMERCE-6866](https://jira.tools.weblinc.com/browse/ECOMMERCE-6866)

### Pull Requests

- [3979](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3979/overview)

## Fix Running System Tests On Chrome 74+

Chrome's latest major release caused timeout issues when running with
the bundled version of ChromeDriver. Since [ChromeDriver::Helper has been abandoned](https://github.com/flavorjones/chromedriver-helper/issues/83),
we've replaced the gem with [Webdrivers](https://github.com/titusfortner/webdrivers), a more generic Selenium
webdriver helper that downloads the correct ChromeDriver packages when
needed for system tests. This also required a version bump for Capybara
in order to sufficiently use the new Selenium WebDrivers.

### Issues

- [ECOMMERCE-6867](https://jira.tools.weblinc.com/browse/ECOMMERCE-6867)

### Pull Requests

- [3980](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3980/overview)

