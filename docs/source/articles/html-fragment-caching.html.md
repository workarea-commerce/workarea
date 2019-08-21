---
title: HTML Fragment Caching
created_at: 2019/03/14
excerpt: After HTTP caching The next level of caching happens in the Rails views. The Workarea system does this fragment caching in the conventional Rails way, so if you've worked with caching on Rails systems before this will be familar to you.
---

# HTML Fragment Caching

After [HTTP caching](http-caching.html) The next level of caching happens in the Rails views. The Workarea system does this fragment caching in the conventional Rails way, so if you've worked with caching on Rails systems before this will be familiar to you.

storefront/app/views/workarea/storefront/categories/show.html.haml:

```
- cache "#{@category.cache_key}/head", expires_in: Workarea.config.cache_expirations.categories_fragment_cache do
  = append_partial('admin.category_head', category: @category)

  - if @category.first_page?
    %link{ href: category_url(@category), rel: 'canonical' }
  - unless @category.last_page?
    %link{ href: url_for(page: @category.next_page, only_path: false), rel: 'next' }
  - unless @category.first_page?
    %link{ href: url_for(page: @category.prev_page, only_path: false), rel: 'prev' }
  - unless @category.meta_keywords.blank?
    %meta{ name: :keywords, content: @category.meta_keywords }
  - unless @category.meta_description.blank?
    %meta{ name: :description, content: @category.meta_description }

  %meta{ property: 'og:url', content: url_for(only_path: false) }
  %meta{ property: 'og:title', content: page_title }
  %meta{ property: 'og:type', content: 'website' }
  %meta{ property: 'og:image', content: image_path('workarea/storefront/logo.png') }
  %meta{ property: 'og:image:secure_url', content: image_path('workarea/storefront/logo.png') }
```

In the Rails views, a chunk of HTML is wrapped in a `cache` block. When that `cache` block is hit, Rails fetches the key from the cache store and returns the value. If the key doesn't exist or is expired, the code in the `cache` block will be run, and the result is saved in the cache store. Examples of fragment caches include:

- Primary navigation menus
- Secondary navigation menus
- Product summaries (shown on browse pages and recommendations)
- Browse results

When defining any fragment caches, keep in mind cache expiration. The simplest way to handle this is to use the updated\_at timestamp of the correlating model to ensure this cache will be expired when the model is updated.

## Resources on Fragment Caching

- [Rails Guide: Fragment Caching](http://guides.rubyonrails.org/caching_with_rails.html#fragment-caching)
- [Heroku: Fragment Caching](https://devcenter.heroku.com/articles/caching-strategies#fragment-caching)
