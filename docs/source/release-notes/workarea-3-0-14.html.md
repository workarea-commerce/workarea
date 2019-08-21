---
title: Workarea 3.0.14
excerpt: Workarea 3.0.14 modifies links to content assets within the Admin to use the correct asset host (e.g. a CDN for production environments), via the url_to_asset helper.
---

# Workarea 3.0.14

## Fixes Admin Content Asset Links Not Using CDN

Workarea 3.0.14 modifies links to content assets within the Admin to use the correct asset host (e.g. a CDN for production environments), via the `url_to_asset` helper.

### Issues

- [ECOMMERCE-5139](https://jira.tools.weblinc.com/browse/ECOMMERCE-5139)

### Pull Requests

- [2764](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2764/overview)

### Commits

- [ffd54679719b68ad7721ed9be52d83a13696295f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ffd54679719b68ad7721ed9be52d83a13696295f)
- [9696132a8023732a56cace239bb4cd7b680bb37a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9696132a8023732a56cace239bb4cd7b680bb37a)

## Fixes Admin "Small" Number Fields Obscuring Value

Workarea 3.0.14 fixes the display of _text-box--small_ elements of type _number_ in the Admin. The browser's "spinner" UI was obscuring the value of these fields. This change widens these fields to resolve the issue.

### Issues

- [ECOMMERCE-5185](https://jira.tools.weblinc.com/browse/ECOMMERCE-5185)

### Pull Requests

- [2769](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2769/overview)

### Commits

- [345eacb26a20c62770309372830593000f22e4f1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/345eacb26a20c62770309372830593000f22e4f1)
- [0db48a7e2d7bde4a601a0dd20a0678be32f14c42](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0db48a7e2d7bde4a601a0dd20a0678be32f14c42)
- [e31cb1a7d0fe15cb3792b832c6d4eecb019add99](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e31cb1a7d0fe15cb3792b832c6d4eecb019add99)

## Improves Admin Releases Calendar by Varying Release Colors

Workarea 3.0.14 modifies the Admin releases calendar, varying the color of each release represented on the calendar. This improves the usability of the calendar when multiple releases are visible on the same screen. The color of each release is determined programmatically, based on the name of the release.

### Issues

- [ECOMMERCE-5173](https://jira.tools.weblinc.com/browse/ECOMMERCE-5173)

### Pull Requests

- [2767](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2767/overview)

### Commits

- [f4a0b4574c7e50467987b8572730242de8613173](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f4a0b4574c7e50467987b8572730242de8613173)
- [203b43ca8acf3544451edd82f0605c641b58606e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/203b43ca8acf3544451edd82f0605c641b58606e)

## Improves Presentation of Date-Time-Pickers in Releases Admin

Workarea 3.0.14 modifies two releases views in the Admin to improve the presentation of adjacent date-time-picker controls.

### Issues

- [ECOMMERCE-5173](https://jira.tools.weblinc.com/browse/ECOMMERCE-5173)

### Pull Requests

- [2767](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2767/overview)

### Commits

- [c57af70cc34370d9691e9baaf062fec8f9fd9e87](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c57af70cc34370d9691e9baaf062fec8f9fd9e87)
- [203b43ca8acf3544451edd82f0605c641b58606e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/203b43ca8acf3544451edd82f0605c641b58606e)

## Adds "Rounded" Admin Boxes

Workarea 3.0.14 adds a _rounded_ modifier for use with the Admin _box_ component.

### Issues

- [ECOMMERCE-5173](https://jira.tools.weblinc.com/browse/ECOMMERCE-5173)

### Pull Requests

- [2767](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2767/overview)

### Commits

- [85f013cd6ff4cd51ecf1f6b5f5e70e330d432c9a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/85f013cd6ff4cd51ecf1f6b5f5e70e330d432c9a)
- [203b43ca8acf3544451edd82f0605c641b58606e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/203b43ca8acf3544451edd82f0605c641b58606e)

