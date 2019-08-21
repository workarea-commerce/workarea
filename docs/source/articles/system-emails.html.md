---
title: System Emails
excerpt: System emails are sent from both the admin and storefront engines. All system emails may be customized like any other view in the system, by first overriding the mailer views and associated stylesheets.
---

# System Emails

System emails are sent from both the admin and storefront engines. All system emails may be customized like any other view in the system, by first [overriding](overriding.html) the mailer views and associated stylesheets.

In both the admin and storefront emails are comprised of

- an email view layout
- a number of mailer views, all wrapped in the email view layout
- an email stylesheet manifest, referenced by the email view layout
- a number of stylesheets, all referenced by the email stylesheet manifest

Unlike the front-end of either engine, the stylesheets responsible for styling the system emails are minimial. They are independent from their respective engine's styling, in that they have a separate manifest, but styles can be pulled in from the parent engine easily.

An example of can be found in the `email/_settings.scss` file:

```
/*------------------------------------*\
#SETTINGS
\*------------------------------------*/

/**
* In this file you can override a variables !default value before it is
* imported, effectively adjusting the theme of the site for the site's emails.
*/

$font-size: 16px !default;

@import 'workarea/storefront/settings/colors';
@import 'workarea/storefront/settings/global';
@import 'workarea/storefront/settings/typography';

/**
* Email-specific variables are defined separately.
*/

$email-max-width: 600px !default;
$email-background-color: $light-gray !default;
```

In the above example the `@import` directives here are pulling in the settings from the parent engine for use within the emails.

## Customize System Emails

### The Template

The actual template contained within the email layout is derived from the [Hybrid Cerberus](https://github.com/TedGoas/Cerberus) template. It was chosen because of its wide adoption, semantic versioning, and active community.

Keeping with the spirit of the project, all comments were retained as the template was converted from HTML to Haml for our use in Workarea. Reading through the layout once should give you a clear picture of what the template is attempting to do.

Another diversion from the original template was the removal of all inline CSS, excluding those defined in the `head` of the document. Ultimately the template is rendered through [Premailer](https://github.com/fphilipe/premailer-rails), which automatically transforms external CSS into inline CSS.

### Premailer

Premailer's role is to parse an email with a linked, external stylesheet file and apply any the styles defined as inline CSS to each matching element. In short this helps developers write CSS in the way they are accostomed without having to endure the mental gymnastics of classical email template development.

Here is a contrived example of how Premailer works. Given the following CSS:

```
/** from 'workarea/storefront/email/_base.scss' */
$font-size: 16px !default;
$line-height: 1.5 !default;

p {
font-size: $font-size;
line-height: $line-height;
}
```

And template:

```
...
<body>
<p>Hello World!</p>
</body>
...
```

Premailer will provide:

```
...
<body>
<p style='font-size: 16px; line-height: 1.5;'>Hello World!</p>
</body>
...
```

Another helpful feature Premailer provides is automatically generated text-only versions of each email template. These text-only emails should be satisfactory out-of-the-box, but if customization is required, they can be manually created and customized to your liking.

## Preview System Emails in a Browser

Rails provides functionality to [preview emails in a browser](http://api.rubyonrails.org/v4.1/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails). All Workarea emails provide previews out of the box.

View an index of email previews at the following path in your app: _/rails/mailers/_


