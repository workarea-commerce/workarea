---
title: Translate or Customize Static Content
created_at: 2019/03/14
excerpt: All static, user-facing text in Workarea UIs (including messages and emails) is translated through Rails' t helper. Use of this helper is explained in the Rails Internationalization (I18n) API guide.
---

# Translate or Customize Static Content

All static, user-facing text in Workarea UIs (including messages and emails) is translated through Rails' `t` helper. Use of this helper is explained in the [Rails Internationalization (I18n) API guide](http://guides.rubyonrails.org/i18n.html).

Translations are loaded from Yaml files in `config/locales` within your app.

workarea-storefront/app/controllers/workarea/storefront/cart\_items\_controller.rb:

```
# ...

flash[:success] = t('workarea.storefront.flash_messages.cart_item_added')

# ...

flash[:error] = t('workarea.storefront.flash_messages.cart_item_error')

# ...
```

workarea-storefront/app/views/layouts/workarea/storefront/application.html.haml:

```
.value= email_field_tag :email, nil, id: 'footer_email_signup_field', class: 'text-box', placeholder: t('workarea.storefront.forms.email_placeholder'), title: t('workarea.storefront.users.email'), required: true
created_at: 2019/03/14
```
