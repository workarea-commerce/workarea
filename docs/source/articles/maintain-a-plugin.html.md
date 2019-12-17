---
title: Maintain a Plugin
created_at: 2018/09/17
excerpt: If you've created a plugin for your team to re-use across projects or to share with other teams, you will want to maintain the plugin to respond to bug reports and keep the plugin in sync with supported versions of the Workarea platform. While how you
---

# Maintain a Plugin

If you've created a plugin for your team to re-use across projects or to share with other teams, you will want to maintain the plugin to respond to bug reports and keep the plugin in sync with supported versions of the Workarea platform. While how you do this is up to you, you may want to model your workflow after the plugins maintained by the Workarea core team.

Core team plugins generally follow [Semantic Versioning](http://semver.org/) to determine how many releases to do and the type of releases. The first public release of a plugin is 0.1.0 or 1.0.0. From there, bugs are fixed in patch releases (e.g. 0.1.1) features are added or changed in minor releases (e.g. 0.2.0). Version 1.0.0 should be released when the plugin's API is considered stable. Version 2.0.0 (and subsequent major releases) would introduce breaking API changes.

Long living git branches exist that correspond to version numbers, as explained in the [contributing guide](/articles/contribute-code.html). Work is completed in topic branches and then merged into these long living branches once approved.
