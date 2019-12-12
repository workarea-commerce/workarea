---
title: Translate or Customize Message Content
created_at: 2019/03/14
excerpt: Message text is translated/customized in the same manner as all static text.
---

# Translate or Customize Message Content

Message text is translated/customized in the same manner as all [static text](/articles/translate-or-customize-static-content.html).

To customize or translate message text, create a local file in your app for each locale (if you haven't already) and edit the values for the keys that correspond to the messages you'd like to change.

your\_app/config/locales/en.yml :

```
en:
  workarea:
    storefront:
      # ...
      flash_messages:
        error: Error
        no_search_query: You must enter a search term.
        no_matching_order: We could not find a matching order. Please try again.
        email_signed_up: Your email address has been added to our list.
        email_signup_error: The provided email address was invalid.
        contact_message_sent: Your message has been sent.
        share_message_sent: Thanks for sharing! An email has been sent to %{recipient}.
        # ...
      # ...
```
