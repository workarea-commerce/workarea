---
title: Configure Contact Form Subjects List
excerpt: Use config.inquiry_subjects to configure the subject line options presented to users in the contact form. The value is a hash in the form { 'slug' => 'description' }.
---

# Configure Contact Form Subjects List

Use `config.inquiry_subjects` to configure the subject line options presented to users in the contact form. The value is a hash in the form `{ 'slug' => 'description' }`.

your\_app/config/initializers/workarea.rb:

```
Workarea.configure do |config|
  config.inquiry_subjects = {
    'orders' => 'Orders',
    'returns' => 'Returns and Exchanges',
    'products' => 'Product Information',
    'feedback' => 'Feedback',
    'general' => 'General Inquiry'
  }
end
```


