---
title: JavaScript Templates
created_at: 2018/07/31
excerpt: Templates are client-side view files used to generate HTML strings for use within modules.
---

# JavaScript Templates

Templates are client-side view files used to generate HTML strings for use within modules.

Template files end in the extensions `.ejs`. Each file is compiled using Webpack's [ejs-compiled-loader](https://github.com/bazilio91/ejs-compiled-loader) when imported, and delivered to the browser as a function. The following is a simple template that expects `name` and `value` to be passed in.

```
<input type="hidden" name="<%= name %>" value="<%= value %>">
```

Each template function must be imported into application code when it is needed. These template functions take an object as arguments, with key/value pairs corresponding to the named arguments in the template. For example, if the aforementioned template was located at **storefront/templates/hidden_input.ejs**, you could use it into your controller like so:

```javascript
import HiddenInput from "storefront/templates/hidden_input.ejs"

export default class HiddenController extends Controller {
  connect() {
    const input = HiddenInput({ name: 'foo', value: 'bar' })

    this.element.insertAdjacentHTML("beforeend", input)
  }
}
```

This will add the following element underneath the element that this controller is conneted to:

```
<input type="hidden" name="Foo" value="Bar">
```
