---
title: Workarea 3.6.0 Upgrade Guide
excerpt: Changes requiring attention when upgrading to Workarea 3.6.0
---

# Workarea 3.6.0 Upgrade Guide

---

__Upgrading to Workarea 3.6?__ &mdash; Check out the [Workarea 3.6 Release Notes](/release-notes/workarea-3-6-0.html)

---

Before upgrading to Workarea 3.6.0, review the following changes.

## Upgrade to Rails 6 and other dependencies

### What's Changing?

Workarea is technology forward platform, and we want to be as up-to-date and possible with our dependencies. As such, v3.6 updates Workarea's Rails dependency to Rails 6. You can read [the Rails release notes](https://edgeguides.rubyonrails.org/6_0_release_notes.html) if you're curious about the changes.

Many other dependencies, like Mongoid and Sidekiq, have been updated as well.


### What Do You Need to Do?

Similar to a Workarea upgrade in general, here are additional steps to take to upgrade your app to Rails 6. There aren't many big API changes that affect Workarea, so this probably won't impact your code too much.

1. Update `workarea` in your Gemfile, and adjust other gems/dependencies as needed to get Bundler resolving (as usual).
2. Run `rails app:update`, this is the script Rails provides to make updates to your app.
3. Check `config/initializers/new_framework_defaults_6_0.rb` and comment/uncomment as needed
4. Get tests passing
