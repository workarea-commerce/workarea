---
title: Rails Asset Manifests
created_at: 2018/07/31
excerpt: Rails ships with a feature known as the asset pipeline, which is covered in detail in this excellent Rails guide. If you're new to Ruby on Rails, that guide and the other Rails guides are your friends.
---

# Rails Asset Manifests

Rails ships with a feature known as the asset pipeline, which is covered in detail in [this excellent Rails guide](http://guides.rubyonrails.org/asset_pipeline.html). If you're new to Ruby on Rails, that guide and the other Rails guides are your friends.

The asset pipeline is used to bundle together assets and optimize them in production environments.

A manifest typically includes special comments, called directives, to add JavaScript files to a bundle. The contents of a **typical Rails manifest** looks something like this:

your\_app/app/assets/javascripts/application.js:

```
//= require jquery
//= require lodash
//= require some_js_file
//= require some_other_js_file
//= require ...
//= require ...
//= require ...
//...
```

You add a manifest like this to your app using [rails asset view helpers](/articles/rails-asset-view-helpers.html) provided by Rails. In a development environment, each file in the manfest is included as a separate `script` element. In production, the assets are concatenated into a single file (named after the manifest) and minified.

## Workarea Asset Manifests

Workarea asset manifests leverage the Rails asset pipeline, but **Workarea's manifest files look a bit different**. See [Add JavaScript through a Manifest](/articles/add-javascript-through-a-manifest.html) for a detailed look at the Workarea manifest files.


