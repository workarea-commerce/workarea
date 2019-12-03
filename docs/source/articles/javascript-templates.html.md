---
title: JavaScript Templates
created_at: 2018/07/31
excerpt: Templates are client-side view files used to generate HTML strings for use within modules.
---

# JavaScript Templates

Templates are client-side view files used to generate HTML strings for use within modules.

Template files end in the extensions `.jst.ejs`. Each file is processed on the server by the [ruby-ejs gem](https://github.com/sstephenson/ruby-ejs) and delivered to the browser as a function. The following is a simple template that expects `name` and `value` to be passed in.

```
<input type="hidden" name="<%= name %>" value="<%= value %>">
```

Each template function is available via the global `JST` object in the browser. Each property of `JST` corresponds to the path of a template file. To render the HTML string, execute the template function, passing in an object of data to be used by the template.

```
JST['workarea/storefront/templates/hidden_input']({name: 'Foo', value: 'Bar'})
```

Which returns:

```
<input type="hidden" name="Foo" value="Bar">
```

## Using Rails Helpers in JST Templates

It's possible to access Rails Helpers in your templates as well. A good example of this is the `inline_svg` helper, which processes an SVG and outputs its contents into the page, rather than rendering it as an image.

To access rails helpers in your template, add a `.ruby` extension to the end of your `.jst.ejs` chain.

The Workarea platform uses the `inline_svg` Rails helper for the Admin's WYSIWYG editor's toolbar icons, loaded in `wysiwyg_toolbar.jst.ejs.ruby`:

```
%Q{

  ...

  <a class='wysiwyg__toolbar-button' data-wysihtml-command='bold'>
    #{ inline_svg_tag('workarea/admin/icons/wysiwyg/bold.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.bold')) }
created_at: 2018/07/31
  </a>

  ...

}
```

The `%Q` command in the first line wraps the entire template, making sure that the output is stringified. Next, because of the way the Asset Pipeline works, all Ruby code is evaluated. This means that the string interpolation will be picked up next, outputting the result of `inline_svg` as a string.


