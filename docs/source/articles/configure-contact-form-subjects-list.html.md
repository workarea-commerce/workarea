---
title: Configure Contact Form Subjects List
created_at: 2020/07/28
excerpt: The default contact page provides a list of subjects for a customer to pick from. These subjects are configurable from the admin to customize the subjects of inquiries on your site.
---

# Configure Contact Form Subjects List

The default contact page provides a list of subjects for a customer to pick from. These subjects are configurable from the admin to customize the subjects of inquiries on your site.

Log into the admin and go to Settings > Configuration. the "Inquiry Subjects" field is in the Communication section and has a list of key-value pairs. The first value of each line is a key used to the store the code-friendly version of the name, while the second value is the human-readable value that is displayed to the user.

![Inquiry subjects](/images/inquiry-subjects.png)

If you would like to provide a different value to visitors to your site based on locale, you can define the key value pair in your locale file, with the keys matching the keys provided in the admin.

```
en:
  workarea:
    inquiry:
      subjects:
        products: Ask about a product
```

Any value provided in a locale will take precedence over the value provided in the admin.
