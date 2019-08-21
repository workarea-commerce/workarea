## Overview

Help articles provide a canonical spot for you or your development team to create helpful reminder documentation. For administrators, creating content is a simple task that can save you and your team time when training or performing repetitive or complex tasks. For developers, documentation can help training clients on how to use features that are created.

## Adding Articles Through the Admin

Navigate to [the Help section](/admin/help) and click on the **Add New Article** button, in the bottom right of the page, to get started. On the resulting page, the:

* **Title** creates the documents title
* **Thumbnail** is optional and can help visually identify the article in a list
* **Category** helps categorize the document
* **Matching URL** is optional but can be used to more accurately recommend the article when a user is on a given page
* **Summary** is used in article listings
* **Body** is the main body of the article

The article's body is composed in [Markdown](https://daringfireball.net/projects/markdown/syntax) for your convenience.

Adding assets to the body of a document can be achieved through [the Help Assets section](/admin/help_assets). Simply add an asset to this page and copy its resulting URL from the **Link** column once it has finished uploading. Once copied you can insert it into your document using the Markdown Image syntax.

## Adding Articles to Seed Data

Developers may automate the creation of their help articles by adding them directly to their app via the `data/` directory.

Each article found within `data/help/CATEGORY` will be automatically saved to the database during a seed. If you are not performing a full re-seed of the database then you may use any of these tasks to load help articles into the Admin:

```shell
rails workarea:reload_help         # Drop and recreate help articles (Warning: all current help will be deleted
rails workarea:search_index:help   # Reindex help
rails workarea:upgrade_help        # Upgrade help (creates only new articles that do not exist in the database)
```

And example path structure for a new help article is as follows:

```
data/
|-- help/
|---- howto/
|------ manage_categories/
|-------- body.md
|-------- summmary.md
|-------- thumbnail.png
|-------- assets/
|---------- category_rules.png 
```

As you can see both the structure of the article directory and files help map the data to each corresponding field as though the article was being created by an administrator. See above for a description of each field that will be mapped.

Finally, image linking is provided by automatically created helper methods. In this example, by using ERB syntax to call the `category_rules` method within your Markdown document you can add a link directly to the image using Markdown Image syntax. 

A link comprised in this way will create an image supplied in the `assets/` directory for this article.
