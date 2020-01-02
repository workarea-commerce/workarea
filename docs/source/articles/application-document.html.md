---
title: Application Document
created_at: 2018/07/31
excerpt: An application document is a persistable model with a global id, timestamps, an audit log, and life cycle callbacks providing hooks for callbacks workers. An application document cleans some of its data before validation and before create.
---

# Application Document

An <dfn>application document</dfn> is a persistable model with a global id, timestamps, an audit log, and life cycle callbacks providing hooks for [callbacks workers](/articles/workers.html#callbacks-worker). An application document cleans some of its data before validation and before create.

## Mongoid

Workarea employs [Mongoid](https://rubygems.org/gems/mongoid) ([docs](https://docs.mongodb.com/ruby-driver/master/mongoid/), [source](https://github.com/mongodb/mongoid)), MongoDB's <abbr title="object document mapper">ODM</abbr> written in Ruby, to map between in-memory models and documents persisted to disk.

### Document

An application document includes the `Mongoid::Document` module ([docs](https://docs.mongodb.com/ruby-driver/master/tutorials/6.1.0/mongoid-documents/), [docs](http://www.rubydoc.info/gems/mongoid/6.0.0/Mongoid/Document)), providing a large API for document persistence, queries, relations, callbacks, validations, indexes, and more.

### Timestamps

An application document also includes Mongoid's `Mongoid::Timestamps` module ([docs](http://www.rubydoc.info/gems/mongoid/6.0.0/Mongoid/Timestamps)), which provides timestamp fields and accessor methods such as `ApplicationDocument#created_at` and `ApplicationDocument#updated_at`.

### Audit Log

An application document additionally includes the `Mongoid::AuditLog` module ([docs](http://www.rubydoc.info/gems/mongoid-audit_log/0.4.0/Mongoid/AuditLog)) from the [mongoid-audit\_log](https://rubygems.org/gems/mongoid-audit_log) library ([docs](http://www.rubydoc.info/gems/mongoid-audit_log/0.4.0), [source](https://github.com/bencrouse/mongoid-audit_log)). This library provides basic audit logging for each application document. `ApplicationDocument#audit_log_entries` provides access to the audit log entries for an application document instance.

## Global ID

An application document includes `GlobalID::Identification` ([docs](http://www.rubydoc.info/gems/globalid/0.3.7/GlobalID/Identification)), providing the model with a global id that is guaranteed to be unique within the application, independent of its type.

## Callbacks Workers

An application document includes `Sidekiq::Callbacks`, providing `ApplicationDocument#run_callbacks`, an extension of `ActiveSupport::Callbacks#run_callbacks` ([docs](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html#method-i-run_callbacks)) allowing [callbacks workers](/articles/workers.html#callbacks-worker) to run or enqueue in response to the document's life cycle callbacks, such as `after_save` and `after_destroy`.

## Data Cleaning

An application document cleans array fields before validation and ensures default locale values before create.

### Reject Blank Array Members

Before validation, each field value of type `Array` is cleaned to remove blank members.

```
category = Workarea::Catalog::Category.new(terms_facets: ['color', '', nil, 'size'])

category.terms_facets
# => ["color", "", nil, "size"]

category.validate

category.terms_facets
# => ["color", "size"]
```

### Ensure Default Locale Values

Before create, for each localized field with a value, the value is copied to the default locale if that value is blank within the default locale. Ensuring a value for the default locale avoids a class of errors when locales switch or fall back.

```
I18n.default_locale
# => :en

I18n.locale
# => :en

# change to non-default locale
I18n.locale = :fr

I18n.locale
# => :fr

# within this locale, create a product with a name (a localized field)
red_dress = Workarea::Catalog::Product.create!(name: 'Robe Rouge')

red_dress.name
# => "Robe Rouge"

# switch back to the default locale
I18n.locale = I18n.default_locale

# the 'name' value from the :fr locale has been copied to the :en locale to
# avoid errors when switching or falling back
red_dress.name
# => "Robe Rouge"

# red_dress.name_translations
# => {"fr"=>"Robe Rouge", "en"=>"Robe Rouge"}
```

