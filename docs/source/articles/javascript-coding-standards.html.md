---
title: JavaScript Coding Standards
created_at: 2018/07/31
excerpt: In addition to using a standard module structure, modules generally follow the coding style of Douglas Crockford.
---

# JavaScript Coding Standards

In addition to using a standard module structure, modules generally follow the [coding style of Douglas Crockford](http://javascript.crockford.com/code.html).

To enforce code style rules, we use [ESLint](http://eslint.org/).

```
npm install -g eslint
```

Each Workarea gem includes a `.eslintrc` file to configure ESLint. The following rules are also observed:

- Unless unavoidable, do not use the keyword `this`. Functions passed to jQuery's `on` and `each` methods include parameters that provide access to relevent DOM elements and data, so `this` is almost never required in Workarea modules. Avoid jQuery iteration methods that do not pass the current element as an argument to the iterator, such as the function form of `.attr`. Use `.each` instead.
- When chaining methods across multiple lines, indent/outdent only when the return value changes. 
```
$('.product-form')
    .find('fieldset')
        .first()
        .attr('id', 'first')
    .end()
.end()
.attr('id', 'cart-form')
    .serializeArray();
```

