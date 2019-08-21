---
title: Workarea 3.0.28
excerpt:  Moving content blocks caused boolean values to be typecasted improperly when they were being re-saved, thus causing their value to return back to default. We're now converting the value of a boolean field to String before attempting to typecast it, e
---

# Workarea 3.0.28

## Preserve boolean type when content blocks are moved

Moving content blocks caused boolean values to be typecasted improperly when they were being re-saved, thus causing their value to return back to default. We're now converting the value of a boolean field to String before attempting to typecast it, ensuring consistent behavior between creating and updating content blocks.

### Issues

- [ECOMMERCE-5722](https://jira.tools.weblinc.com/browse/ECOMMERCE-5722)

### Pull Requests

- [3147](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3147)

### Commits

- [bf679c113aadd5ed69e6001938b40c7e89ee8561](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bf679c113aadd5ed69e6001938b40c7e89ee8561)

## Remove Duplicates in Recommendations

Since the possibility of returning the same product twice in a series of recommendations does indeed exist, we're now ensuring that each product only appears once when displaying recommendations.

## Issues

- [ECOMMERCE-5743](https://jira.tools.weblinc.com/browse/ECOMMERCE-5743)

### Pull Requests

- [3148](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3148/overview)

### Commits

- [6ac7c19e78f468e6daeadb22545f8a1ed03e3774](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6ac7c19e78f468e6daeadb22545f8a1ed03e3774)

