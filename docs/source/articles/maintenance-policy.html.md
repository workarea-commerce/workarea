---
title: Maintenance Policy 
created_at: 2019/05/21
excerpt: Learn how we version our software and what to expect in each release. 
---

Workarea bases its releases on a shifted version of [semver](http://semver.org/) and handles its releases very similarly to [the way Rails handles its versioning](https://guides.rubyonrails.org/maintenance_policy.html).

# Semver Overview

Support for Workarea is divided into four groups: New features, bug fixes, security issues, and severe security issues. They are handled as follows, all versions in __X.Y.Z__ format: 

__Patch Z__

Only bug fixes, no API changes, no new features. Except as necessary for security fixes. Typically a patch is released every 2 weeks.

__Minor Y__

New features, may contain API changes (Serve as major versions of Semver). Breaking changes are paired with deprecation notices in the previous minor or major release where applicable. Typically a minor is released every quarter.

__Major X__

New features, will likely contain API changes. The difference between minor and major releases is the magnitude of breaking changes.

# Release Overview

## New Features

New features are only added to the `master` branch and will not be made available in point releases.

## Bug Fixes

The current major release series and its minors will recieve bug fixes. When a new major is released, the previous major release will recieve support that will eventually dwindle within a reasonable amount of time. Bugs are fixed in the oldest branch where they are found. Before a release each branch is merged downstream so that each release contains the fix.

Series currently supported and branches from which fixes are released:

* v3.0.Z from `v3.0-stable`
* v3.1.Z from `v3.1-stable`
* v3.2.Z from `v3.2-stable`
* v3.3.Z from `v3.3-stable`
* v3.4.Z from `v3.4-stable`

## Security Issues

The current major release series and its minors will recieve security fixes. When a new major is released, the previous major release will recieve support that will eventually dwindle within a reasonable amount of time. Bugs are fixed in the oldest branch where they are found. Before a release each branch is merged downstream so that each release contains the fix. Patches containing security issues are released as soon as possible.

Series currently supported and branches from which fixes are released:

* v3.0.Z from `v3.0-stable`
* v3.1.Z from `v3.1-stable`
* v3.2.Z from `v3.2-stable`
* v3.3.Z from `v3.3-stable`
* v3.4.Z from `v3.4-stable`

## Severe Security Issues

The current major release series and its minors will recieve severe security fixes. When a new major is released, the previous major release will recieve support that will eventually dwindle within a reasonable amount of time. Bugs are fixed in the oldest branch where they are found. Before a release each branch is merged downstream so that each release contains the fix. Patches containing severe security issues are released as soon as possible.

Series currently supported and branches from which fixes are released:

* v3.0.Z from `v3.0-stable`
* v3.1.Z from `v3.1-stable`
* v3.2.Z from `v3.2-stable`
* v3.3.Z from `v3.3-stable`
* v3.4.Z from `v3.4-stable`

## Unsupported Release Series

When a release series is no longer supported, it's your own responsibility to deal with bugs and security issues. We may provide backports of the fixes and publish them to git, however there will be no new versions released. If you are not comfortable maintaining your own versions, you should upgrade to a supported version.

# Feedback

You're encouraged to help improve the quality of this guide.

Please contribute if you see any typos or factual errors. To get started, you can read our [documentation contributions section](/articles/contribute-documentation.html).

Branches containing documentation fixes should originate from the latest stable branch for the current minor version.

If for whatever reason you spot something to fix but cannot patch it yourself, please open an issue.
