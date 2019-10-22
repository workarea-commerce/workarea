---
title: Add JavaScript through the Admin UI
created_at: 2018/10/11
excerpt: JavaScript can be added on a page by page basis through the Admin UI. To do so, visit a content edit page in the Admin, such as the home page edit screen.
---

# Add JavaScript through the Admin UI

JavaScript can be added on a page by page basis through the Admin UI. To do so, visit a content edit page in the Admin, such as the home page edit screen.

<!-- TODO: add image of home page edit screen -->

Hover over the Content card and click the "Manage Content" button.

<!-- TODO: add image of hover interaction -->

Click the "Advanced" link at the top of the Content Editor UI.

<!-- TODO: add image of Content Editing UI, "Advanced" link highlighted -->

Here you are able to append JavaScript to either the `head` or `body` elements via the __Content Appended to Head Element__ or __JavaScript Appended to Body Element__ fields, respectively. The former field allows content other than JavaScript, so be sure to wrap your JavaScript in a `<script>` tag. The latter field only accepts JavaScript, so you should omit the `<script>` tag.

<!-- TODO: update image
    <p><%= image_tag "images/js-admin-ui.png", alt: "CSS field in Admin" %></p>
    -->

Visit the home page in the Storefront and behold! JavaScript!

<!-- TODO: update image
    <p><%= image_tag "images/js-added-through-admin.png", alt: "CSS added through Admin" %></p>
    -->
