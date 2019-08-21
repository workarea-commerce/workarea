---
title: Feature.js & Feature Test Helper
created_at: 2018/07/31
excerpt: Feature.js provides browser feature detection for developers. It is loaded in its entirety in the Storefront's head manifest. Out of the box it provides JavaScript methods and root HTML element classes that represent which features are available to th
---

# Feature.js & Feature Test Helper

## Feature.js

[Feature.js](http://featurejs.com) provides browser feature detection for developers. It is loaded in its entirety in the Storefront's head manifest. Out of the box it provides JavaScript methods and root HTML element classes that represent which features are available to the developer to program against.

## Feature Test Helper

After Feature.js does all that hard work to set up the features above, Workarea's feature test helper file works equally hard (at least I like to think so) to undo a portion of it. However, it only does this if the Rails environment is `test`.

Some styles, particularly CSS animations and transitions, interfere with full stack testing and make it difficult to write reliable tests. Workarea therefore applies additional styles in the test environment to effectively disable all animations and transitions.

However, Feature.js is not aware of this and still reports those features as supported. The feature test helper updates the class values on the html element to report animations and transitions as not supported overwrites the corresponding properties on the `Feature.js` object to do the same.


