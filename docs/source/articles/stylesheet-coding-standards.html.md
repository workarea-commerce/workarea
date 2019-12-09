---
title: Stylesheet Coding Standards
created_at: 2018/07/31
excerpt: The files that make up the Workarea CSS Framework adhere to specific architectural guidelines. The architecture defines specific layers to which each CSS file should belong. For more information, read through the CSS Architectural Overview section.
---

# Stylesheet Coding Standards

## Architecture

The files that make up the Workarea CSS Framework adhere to specific architectural guidelines. The architecture defines specific layers to which each CSS file should belong. For more information, read through the [CSS Architectural Overview](/articles/css-architectural-overview.html) section.

## BEM

The term block comes from BEM: Block, Element, Modifier. The [BEM philosophy and syntax](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/) is used when constructing [Components](/articles/css-architectural-overview.html#the-components-layer) in the Workarea platform.

## CSS Style Guide

Workarea has published a [SCSS style guide on Github](https://github.com/weblinc/scss-style-guide) to help keep developers writing clean, consistent code.

## Linting

Workarea stylesheets are linted using the [scss-lint gem](https://rubygems.org/gems/scss-lint). A `.scss-lint.yml` file in each Workarea repository configures the linter.


