---
title: Schema.org Structured Data
created_at: 2019/03/28
excerpt: Learn how Structured Data is managed in the Workarea platform 
---

# Schema.org Structured Data 

[Schema.org](https://schema.org), as defined, is a "collaborative, community activity with a mission to create, maintain, and promote schemas for structured data on the Internet, on web pages, in email messages, and beyond." This initiative was launched by Google, Microsoft, Yahoo, and Yandex back in 2011 and is now [fully open source and community maintained](https://github.com/schemaorg/schemaorg). It helps search engines, among other services, quickly understand and consume specific information contained within the pages of any website. This schema can be written in many formats, including RDFa, Microdata and JSON-LD.

The Workarea platform has historically provided this data in Microdata format. Starting with version 3.5, however, we have switched over to JSON-LD format for the following reasons. JSON-LD is:

* now the recommended standard
* more easily customizable for the developer
* allows more freedom in where it is placed on the page
* decouples data from the on-page markup, reducing validity errors 

## Types of Data

Structured Data offers a way to describe many types of content that may be available on a given page of a website. The base Workarea Storefront is concerned with these main types of data:

* [WebSite](https://schema.org/WebSite)
* [WebPage](https://schema.org/WebPage)
* [BreadcrumbList](https://schema.org/BreadcrumbList)
* [Product](https://schema.org/Product)

We also provide a few other schemas that are email specific out of the box. These are:

* [Order](https://schema.org/Order)
* [ParcelDelivery](https://schema.org/ParcelDelivery)
  * [TrackAction](https://schema.org/TrackAction)
* [ViewAction](https://schema.org/ViewAction) (in the Storefront and Admin)

These email-specific schemas allow services, like Gmail, to add custom user interfaces to the emails sent by the system. For Orders and ParcelDelivery schema, Gmail will produce a neat UI inline with the email to help a customer understand what they've purchased and when it will get there.

For mailers that provide a link back to the application, we provide schema that allows Gmail to create a nice, little button that is displayed inline with the subject of the email, allowing users to click through to the application instead of having to first open the message to find the link to click.

Many plugins add their own schemas to this list as well, creating a larger offering of schema available for consumption by 3rd parties.

## Helpers

As of version 3.5, the on-page Structured Data is provided by a series of helpers, namely:

* `Workarea::SchemaOrgHelper` for schemas common to the Admin and Storefront, and
* `Workarea::Storefront::SchemaOrgHelper` for the Storefront only.

As helpers, the contained methods may be [customized](/articles/customize-a-helper.html) the same as any other helper, allowing you to more easily add additional schema to the baseline already provided by the platform.
