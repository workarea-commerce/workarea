---
title: Workarea 3.0.3
excerpt: Commit
---

# Workarea 3.0.3

## Allows Ruby 2.4

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/88e417e07cd5b506d59296805a12cd6ea0083d27)

Workarea 3.0.3 changes the Testing dependency on [webmock](https://rubygems.org/gems/webmock) to `'~> 3.0.1'` and the Core dependency on [dragonfly](https://rubygems.org/gems/dragonfly) to `'~> 1.1.2'`, which allows Workarea's required Ruby version constraint to be updated to `'>= 2.3.0'`. Applications using Workarea 3.0.3 can therefore optionally use Ruby 2.4.x. If your application is segfaulting in the Development environment, upgrade to Workarea 3.0.3 and Ruby 2.4.

## Runs Minitest Reporters in CI

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/37290bd97e8b1841a3be4f5316fcc83866fe5f2b), [Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4cc5d86e88696c7ebbb068797ad6b46ab21e6902)

Workarea 3.0.3 adds a Testing dependency on [minitest-reporters](https://rubygems.org/gems/minitest-reporters) and runs the reporters in the <abbr title="continuous integration">CI</abbr> environment. To skip the reporters, set the environment variable `REPORTERS=false`.

## Adds Append Point to Admin Users Cards Partial

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2482/overview)

Workarea 3.0.3 adds the _admin.user\_cards_ append point to the _workarea/admin/users/\_cards.html.haml_ Admin partial. If your application is overriding this partial, update your copy so that plugins may append to it.

## Changes App Template API

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2cb64560567686ce24745c2b8c1d224cfba3db80)

The <dfn>app template</dfn> provided with Workarea (at _docs/guides/source/app\_template.rb_) is used with the `rails new` command from Rails to create a new Workarea application. The app template provides an API in the form of environment variables that are recognized to provide data and options to the template. Workarea 3.0.3 makes the following changes to the app template API.

- Uses `WORKAREA_PLUGINS_ROOT_PATH` instead of `GEMS_PATH` to specify the path to local plugin sources
- Uses `WORKAREA_PATH` instead of `WORKAREA_DIR` to specify the path to a local Workarea source, relative to the path specified by `WORKAREA_PLUGINS_ROOT_PATH`
- Recognizes only the values `true` and `false` for `WORKAREA_SEED_DATA` (a blank value is no longer equivalent to `false`)

