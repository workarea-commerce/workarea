---
title: Configure Locales
created_at: 2019/03/07
excerpt: Configure locales as explained in the Rails Internationalization (I18n) API guide. For the most foolproof configuration, set available locales, default locale, and fallbacks.
---

# Configure Locales

Configure locales as explained in the [Rails Internationalization (I18n) API guide](http://guides.rubyonrails.org/i18n.html). For the most foolproof configuration, set available locales, default locale, and fallbacks.

```
# config/application.rb

# ...

module YourApp
  class Application < Rails::Application

    # ...

    config.i18n.available_locales = [:en, :de]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:de, :en]

    # ...

  end
end
```

Then, add the full name of the locale to each locale file. This is required for Workarea to recognize and use the locale.

```
# config/locales/en.yml

en:
  name: English
```

## Adding Additional Locales to an Existing App

When adding a locale to an existing Production app, you must consider the impact on search indexes. At a minimum, you must create additional search indexes to account for the additional locale. However, you may also want to index documents as well, to ensure adequate search results within that locale.

Review the [Search](/articles/searching.html) guide to understand the relationship between locales and search indexes.

In Development, there should be no harm in fully re-indexing search by running a [Rake task](/articles/searching.html#rake-tasks) to create and populate the necessary indexes.
