---
title: Extension
created_at: 2018/08/07
excerpt: Extension is the process of adding, modifying, or even removing Workarea platform functionality from within a Workarea application or plugin. Workarea plugins extend the platform in ways that are re-usable across applications, while individual applica
---

# Extension

<dfn>Extension</dfn> is the process of adding, modifying, or even removing Workarea platform functionality from within a Workarea application or plugin. Workarea plugins extend the platform in ways that are re-usable across applications, while individual applications extend the platform further to meet the specific needs of a retailer or other stakeholders. While administration allows for platform customization through a UI, extension allows for deeper customization via code changes.

The code changes performed for extension may conflict with the platform's own code changes between versions. When upgrading to a new version of Workarea, application and plugin developers must resolve these conflicts. Developers must therefore consider the long term cost of extension. Another concern is the initial implementation cost of an extension.

This document provides an overview of extension techniques for easier comparison, while other guides describe various techniques in greater detail.

## Augmentation

One form of extension is simple <dfn>augmentation</dfn>—adding new code within the Workarea namespace. For example, your application may require a calendar of events. Such a feature is entirely new and does not overlap with any existing platform functionality. However, to provide consistent user and developer experiences, it makes sense to add your new code (such as models, views, and controllers) within the Workarea namespace. It also makes sense to leverage Workarea patterns, such as the use of additional object types (e.g. view models, workers), and to follow Workarea conventions (e.g. file naming and structuring).

## Domain-Specific Extension

Workarea provides various _designed_ points of extension that employ conventions, inheritance, DSLs, and other techniques to reduce cost during the initial implementation, and potentially at upgrade time. These techniques are domain-specific, so within this documentation, I cover each where that particular domain aspect is covered. Examples of these extension points are listed below.

- Catalog customizations
- [Content block types](/articles/add-a-content-block-type.html)
- [Discount types](/articles/create-a-custom-discount.html)
- Inventory policies
- Payment tender types, e.g. [credit card tender type](/articles/customize-the-credit-card-tender-type.html)
- [Pricing calculators](/articles/customize-pricing.html)
- Product templates
- Seeds
- Shipping carriers
- Storefront search middlewares

## Generic Extension

Workarea also provides generic extension techniques that apply across domain boundaries and allow for extensions beyond those specifically designed into the platform.

### Configuration

[Configuration](/articles/configuration.html) allows developers to customize specific programmatic values in Ruby and JavaScript.

#### Summary

- Allows applications and plugins to customize configuration values defined by the core platform and plugins
- Allows plugins to define their own configuration values to be customized by applications and other plugins
- Applications and plugins write configuration code within their own Ruby and JavaScript configuration files
- Configuration can affect any aspect of the platform, from the number of products to show in a content block to the list of calculators used to calculate pricing

#### Limitations

- Configuration is limited to specific values defined as configurable by the core platform and plugins
- Most configuration values are simple values (often integers) or collections/lists of those values

#### Test Considerations

- The scope/reach of a configuration tends to be limited, however, configuration may break tests or create the need for new tests
- After configuring your app or plugin, write new tests or decorate existing tests as necessary

#### Upgrade Considerations

- When Workarea makes configuration changes between versions, those changes are generally applied seamlessly to your application or plugin when you upgrade your Workarea version
- However, if Workarea has changed any config values that you have replaced with your own, you will need to apply those changes manually if necessary
- When customizing config values that represent collections, mutate the collection (prepend, append, delete member, etc) rather than replacing it to ensure Workarea's changes to the collection are applied when upgrading
- For example, if adding a product template, append your custom value to the existing list of templates instead of replacing the entire list

### Decoration

[Decoration](/articles/decoration.html) allows developers to customize Ruby classes.

#### Summary

- Allows applications and plugins to customize Ruby classes defined by the core platform and plugins
- Within these customizations, developers may add new instance and class methods, modify existing instance and class methods (with access to the pre-customized implementation via `super`), and execute class macros or other code as if inside the original class definition
- Decoration allows for extensive customization of Ruby code, going far beyond the extension points designed into the platform
- Because test cases are Ruby classes, decoration also allows for customization of the test suite

#### Limitations

- Decoration allows for the customization of Ruby classes only—modules are not supported at this time
- Decoration cannot be used to customize code written using other language or file types (such as JavaScript and other UI code)

#### Test Considerations

- Decoration is likely to break existing tests or create the need for additional tests
- When using decoration to customize functionality, write new tests or decorate existing tests as necessary

#### Upgrade Considerations

- When Workarea changes Ruby code between versions, those changes are generally applied seamlessly to your application or plugin when you upgrade your Workarea version
- However, if Workarea has changed methods you have replaced with your own implementations, you will need to apply those changes manually if necessary
- When decorating classes, change only the aspects of the class necessary for your requirements, and use `super` to maintain original method implementations where possible

### Appending

[Appending](/articles/appending.html) allows developers to inject their own views and assets into existing user interfaces.

#### Summary

- Allows plugins and applications to render their own (new) partials within existing platform views at designated positions
- Allows plugins and applications to include their own (new) assets within existing platform asset manifests
- Plugins and apps create their own partials and assets, and assign these to platform append points within an initializer or other configuration file

#### Limitations

- This technique is limited in scope/reach as it allows only for the injection of new UI code
- Appending generally provides little control over position and display
- New code may be injected into only the designated append points provided by the platform
- There are no formal APIs to remove files from append points or re-order files within append points
- Without also leveraging overriding, you cannot change the position of an append point within a view

#### Test Considerations

- Appending is likely to break existing tests or create the need for additional tests
- When appending files, write new tests or decorate existing tests as necessary

#### Upgrade Considerations

- Appending is a simple way of introducing new code into the platform and therefore has few upgrade concerns
- Unlike other extension techniques, appending is not used to customize existing code; it therefore avoids many of the concerns affecting other extension techniques

### Overriding

[Overriding](/articles/overriding.html) allows developers to replace user interface files such as views and assets with their own customized copies of the files.

#### Summary

- Allows applications (and in rare cases, plugins) to completely replace existing platform views and assets
- Applications copy the views and assets into their own source and customize the files as needed
- Overriding allows developers to completely replace all HTML and assets served by the application, allowing UI customization that goes far beyond any specifically designed extension points

#### Limitations

- Overriding affects only views, layouts, partials, and files served by the asset pipeline (UI customization)
- Except in rare cases, plugins should not use overrides (see [Overriding](/articles/overriding.html) for more on this)

#### Test Considerations

- Overriding is likely to break existing tests or create the need for additional tests
- When overriding, write new tests or decorate existing tests as necessary

#### Upgrade Considerations

- Overriding completely replaces platform files with your own copies
- When Workarea changes views and assets between versions, these changes will not appear in your application if you are overriding the affected files
- You must apply these changes manually to your own copies of the files
- While overriding is necessary for UI customization, try to override only the files necessary for your requirements
- Where possible, use appending instead of overriding to reduce upgrade cost
