---
title: Workarea 3.2.21
excerpt: Patch release notes for Workarea 3.2.21.
---

# Workarea 3.2.21

Patch release notes for Workarea 3.2.21.

## Upgrade Loofah to v2.2.3

Enforce Loofah **v2.2.3** or above to avoid [CVE-2018-16468](https://github.com/flavorjones/loofah/issues/154).

### Issues

- [ECOMMERCE-6420](https://jira.tools.weblinc.com/browse/ECOMMERCE-6420)

### Pull Requests

- [3640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3640/overview)

### Commits

- [30e62511f01518782d91e95c46a162a1db2ce4b3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/30e62511f01518782d91e95c46a162a1db2ce4b3)

## Add Append Point for `<head>` in Admin Layout

Allows plugins to append 3rd party JavaScript within the admin layout's
`<head>` tag if necessary.

### Issues

- [ECOMMERCE-6417](https://jira.tools.weblinc.com/browse/ECOMMERCE-6417)

### Pull Requests

- [3632](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3632/overview)

### Commits

- [ead79c0636ef549d9a8f6442a576dc22b40f90eb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ead79c0636ef549d9a8f6442a576dc22b40f90eb)

## Remove Failing Homebase Ping Test

Applications that have a `.client-id` file inside their repo for
Workarea CLI integration experienced a failing test while upgrading to
the latest patch. Workarea no longer tests for a lack of `client_id`
when pinging home base to avoid this issue.

### Issues

- [ECOMMERCE-6426](https://jira.tools.weblinc.com/browse/ECOMMERCE-6426)

### Pull Requests

- [3642](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3642/overview)

### Commits

- [98b5f138f7d772522d77ccdb126b48ef6920313e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/98b5f138f7d772522d77ccdb126b48ef6920313e)

