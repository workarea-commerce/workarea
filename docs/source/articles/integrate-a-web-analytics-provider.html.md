---
title: Integrate a Web Analytics Provider
created_at: 2018/11/08
excerpt: Workarea analytics adapters are responsible for registering callbacks for events and in turn sending the correctly formatted data and events to the third party.
---

# Integrate a Web Analytics Provider

[Workarea analytics](/articles/analytics-overview.html) adapters are responsible for registering callbacks for events and in turn sending the correctly formatted data and events to the third party.

## Example Adapter

The easiest way to understand how an adapter is implemented is to look at an example. The Workarea platform includes an official Google Analytics plugin, which acts as a Workarea analytics adapter for Google Analytics. Unpack the gem to view its source.

```bash
gem unpack workarea-google_analytics
```

## Adapter Template

Below is a commented template for an analytics adapter.

```javascript
// pass a function that will be invoked by the analtyics framework
WORKAREA.analytics.registerAdapter('myNewAdapter', function () {
    // private methods may be included here
    // return a hash of callbacks for analytics events
    return {
        'pageView': function () { /* pageView calls do not have a payload */ },
        'categoryView': function (payload) { /* send payload */ },
        'searchResultsView': function (payload) { /* send payload */ }
        // ...
    };
});
```

