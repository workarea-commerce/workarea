---
title: System Emails
created_at: 2018/07/31
excerpt: System emails are sent from both the admin and storefront engines. All system emails may be customized like any other view in the system, by first overriding the mailer views and associated stylesheets.
---

# System Emails

System emails are sent from both the admin and storefront engines. All system emails may be customized like any other view in the system, by first [overriding](/articles/overriding.html) the mailer views and associated stylesheets. Emails are sent from the system using [Action Mailer](https://guides.rubyonrails.org/action_mailer_basics.html#), which does most of the heavy lifting. If you're making a new mailer, be sure to read that guide for more information.

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

## Writing Unit Tests for a Mailer

To write unit tests for a mailer that you created, create a file at **test/mailers/workarea/path/to/your_mailer_test.rb** with the following contents:

```ruby
require 'test_helper'

module Workarea
  module Storefront
    class YourMailerTest < Workarea::TestCase
      include TestCase::Mail
      include ActionMailer::TestCase::Behavior
    end
  end
end
```

(If you generated a mailer with `rails generate mailer`, this file should already exist, so just change the contents of the existing file into what's described above.)

You can now use assertions to determine whether mails have been sent:

```ruby
def test_mail_was_sent
  assert_emails(1) do
    valid_user = create_user
    valid_user.send_an_email! # calls YourMailer.some_email.deliver_later
  end
  assert_no_enqueued_emails do
    invalid_user = create_user(send_email: false)
    invalid_user.send_an_email! # fails to call YourMailer.some_email.deliver_later
  end
end
```

[ActionMailer::TestHelper](https://api.rubyonrails.org/v6.0.0/classes/ActionMailer/TestHelper.html) has more information about the assertions you can use here.

## Disable System Emails

There are two configuration values that control the sending of email:

- `Workarea.config.send_email`
- `Workarea.config.send_transactional_emails`

The `send_email` configuration controls whether or not Workarea will send any email. The default value is a lambda that will return `true` for development, testing, and production. For all other environments (e.g. staging and QA), only emails with a recipient email address that matches an admin user's email will be sent. You can change this configuration value in your application, replacing it with either a static boolean value, or a new lambda that returns a boolean. Lambdas will be passed an instance of [`Mail::Message`](https://github.com/mikel/mail) that represents the email being generated.

```ruby
# in config/initializers/workarea.rb
Workarea.configure do |config|
  config.send_email = true # will send all emails

  # or

  config.send_email = lambda { |message|  
    # your logic here
  }
end
```

By default, transactional emails are always enabled and sent if `config.send_email` is true and the SMTP settings are configured to allow the sending of mail. Transactional emails include emails like notifying a user of a refund or a shipping update. The `send_transactional_emails` configuration allows for this behavior to be disabled, since these emails are often handled by a system outside of Workarea.

```ruby
# in config/initializers/workarea.rb
Workarea.configure do |config|
  config.send_transactional_emails = false
end
```
