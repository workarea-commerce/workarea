---
title: Workarea 3.4.25
excerpt: Patch release notes for Workarea 3.4.25.
---

# Workarea 3.4.25

Patch release notes for Workarea 3.4.25.

## Pin Version of `wysihtml-rails`

To address a dependency issue with the `~> 0.x` version occurring with newer
versions of Bundler on `wysihtml-rails`, Workarea has pinned the dependency to
`0.6.0.beta2`.

### Pull Requests

- [305](https://github.com/workarea-commerce/workarea/pull/305)

## Fix Final Test Hard-Coded to 2020

One more test needed to be converted to use the `next_year` helper, and now all
tests should pass out-of-the-box.

### Pull Requests

- [307](https://github.com/workarea-commerce/workarea/pull/307)

## Use Rack Session ID Cookie Value for User Activity Session IDs

Rack versions below v2.0.8 are susceptible to a timing attack, wherein a
session ID can be stolen by inferring how long it takes for the server to
validate it. To address this, Rack has shipped a new version that introduces
private and public session IDs so that these types of attacks can be prevented.
This is mostly applicable to those who store their sessions in a database (such
as Redis), because it is then possible for someone to hijack another user's
session. Workarea does not store sessions in a shared database out-of-the-box,
so it is not inherently vulnerable to such an attack, but had to make a change
since it uses the session ID in the background for user activity reporting. This
change ensures Workarea will be compatible with all future versions of Rack 2.0.

For more information, check out [CVE-2019-16782](https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3).

### Commits

- [cc7d3d8a83d1b4aa15fba894f5cd586b6b5cd325](https://github.com/workarea-commerce/workarea/commit/cc7d3d8a83d1b4aa15fba894f5cd586b6b5cd325)
