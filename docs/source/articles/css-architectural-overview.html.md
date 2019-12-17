---
title: CSS Architectural Overview
created_at: 2018/07/31
excerpt: The main principals of the Workarea CSS architecture were modeled after OOCSS and ITCSS best practices. You will find that the architecture is layered. Each layer has a specific purpose and is naturally more specific than the layer it proceeds. This a
---

# CSS Architectural Overview

The main principals of the Workarea CSS architecture were modeled after OOCSS and ITCSS best practices. You will find that the architecture is layered. Each layer has a specific purpose and is naturally more specific than the layer it proceeds. This allows a developer to think about the purpose of the CSS he or she is writing before dropping it in a corresponding layer, keeping the application manifest direct and to the point.

## _Cascading_ Style Sheets

[Stylesheet manifests](/articles/add-stylesheets-through-a-manifest.html) take your referenced CSS files and produce a concatenated, production-ready file. It's important to note that the order of these files is honored during the concatenation process. This just means that the contents of the files at the top of your manifest will be output before those listed at the bottom of the manifest.

A main pillar of the Workarea CSS architecture is to harness and reinforce the natural cascade of CSS. CSS files are parsed top-to-bottom and precedence is given to CSS rules that appear lower in the code, as seen in this very simple example:

`.component { background: red; }

.component { background: blue; }`

When this code reaches the browser the component is blue, because of the cascade.

Therefore, your most general CSS rules should be found at the top of the manifest, and your most specific CSS rules should be found at the bottom. By always keeping this in mind, you enable yourself to write scalable, purposeful and technically correct CSS.

## Layers

To reinforce the cascade of increasing specificity, the Workarea platform defines specific various CSS layers. All of the CSS files that you write should live in directories named after the file's intended layer. For example, if you create a component for the Storefront called `toggle-button`, that file should live within `workarea/storefront/components/_toggle_button.scss`. This files reference should then be added to the Components layer of the manifest.

I've listed the main layers below. By "main layers" I mean they are the layers that define the core architecture. There are a few plugin-specific layers offered (which I'll cover in a bit), in addition to the following:

1. The Settings Layer
2. The Tools Layer
3. The Generic Layer
4. The Base Layer
5. The Objects Layer
6. The Typography Layer
7. The Components Layer
8. The Trumps Layer

### The Settings Layer

This layer contains variables which are meant to be globally available. They are considered safe for general use and you'll find them peppered throughout the proceeding Sass files.

Each carry a `!default` flag, allowing Theme plugins or multi-site configuration to override their values, if necessary.

### The Tools Layer

This layer contains only functions and mixins. They're helpers that let you dry up your code or perform more complex calculations.

### The Generic Layer

This is the first layer where we start to see some CSS. The Generic Layer is the most global CSS you'll find in the project. We start off with including the [Normalize](https://necolas.github.io/normalize.css/) library, which we tweak the configuration of just a bit in our own reset.css file.

Here is where we set up our global page box-sizing and whatever fonts we'll be using for the project.

### The Base Layer

Now that a sane foundation has been laid, we can begin to apply some default styling to element selectors.

The biggest element we style is the `html` element (in `_page.scss`). Then we ask ourselves what should specific elements look like if we were to just drop them on a page, devoid of classes. This is where your default `table` element and `ul` element styling lives. Each file is grouped thematically, by usage. So the `_forms.scss` file contains default styles for `form`, `input`, and `textarea` tags, for example.

### The Objects Layer

Objects are probably the hardest part of the architecture to grasp. They are intended to be design-free classes and placeholder selectors that allow you to DRY up your codebase. An `inline-list` should remove the bullets of a list and make it's children display horizontally rather than vertically. A `button-reset` should remove all browser styling of a button, so that a component class can start applying design styles in a clear an direct manner.

### The Typography Layer

Here we find all of the text-based styles in the app. All headings are defined here. Utility classes to easily allow a developer to left, right, or center-justify some text are defined here. Links and paragraphs are defined here as well.

### The Components Layer

All of the styles leading up to this layer have ensured that our document looks just like a well formatted document. The Components layer takes that document and makes it into a real website. It provides each of the building blocks needed to achieve layout, the design, and the pleasurable user experience your customers will enjoy.

### The Trumps Layer

Lastly we have the Trumps layer. Trumps are the law. When their classes are applied to an element they are expected to react accordingly. There is no ambiguity in this layer. It contains styles that must be applied, at any cost. If you need to use the `!important` flag on a value, feel free, but you shouldn't have to, since these styles are naturally the most specific.

## Plugin-Specific Layers

In addition to the aforementioned layers, there are a few layers used only by Plugins.

### The Theme Config Layer

Theme Plugins are a special type of plugin who's primary purpose is to make the default Storefront look vastly different. These plugins make use of the Theme Config layer, which appears just before the Settings layer. Theme Plugins can override any Sass variable that carries a `!default` declaration which, out of the box, is every declared variable.

### The Theme Layer

Theme Plugins use this layer to further augment the styling of the system. The Theme layer appears directly after the Components layer, and right above the Trumps layer, to allow increased specificity beyond that of the Components layer.


