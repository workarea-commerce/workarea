---
title: Contentable
created_at: 2018/07/31
excerpt: A contentable is an application document that includes the Workarea::Contentable module, and thereby has a 1:1 relationship with a content.
---

# Contentable

A <dfn>contentable</dfn> is an [application document](/articles/application-document.html) that includes the `Workarea::Contentable` module, and thereby has a 1:1 relationship with a [content](/articles/content.html#content).

Creating a contentable does not create its associated content, so a contentable is not guaranteed to have content. Pass a contentable to `Content.for` to `find_or_create` its associated content. The following examples use a [content page](/articles/content.html#page) as the contentable.

```
# Create a content page
page = Workarea::Content::Page.create!(name: 'Shopping Guide')

# No content yet
page.content
# => nil

# Create content for the page
content = Workarea::Content.for(page)

content.id.to_s
# => "58ac8489eefbfe3e5ac2ae58"

# Access the content from the page
page.reload
page.content.id.to_s
# => "58ac8489eefbfe3e5ac2ae58"

# Access the page from the content
content.contentable_type
# => "Workarea::Content::Page"

content.contentable_id.to_s
# => "58ac8489eefbfe3e5ac2ae56"

content.contentable.name
# => "Shopping Guide"
```

