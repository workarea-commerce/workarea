---
title: Contribute Documentation
created_at: 2018/07/31
excerpt: Learn how to contribute documentation to Workarea
---

# Contribute Documentation

Documentation contributions are welcome. These may be bug fixes or improvements you've identified on your own, or specific changes assigned to you by the Workarea core team.

Use the following process to submit documentation.

## 1. Create a Branch for Your Work

Follow the same process used for [contributing code](/articles/contribute-code.html). [Published documentation](/articles/documentation.html#published-documentation) represents a specific major or minor version of the platform, and you should make a pull request against the highest stable minor branch (e.g. `v3.x-stable`).

## 2. Make Your Changes

Apply your changes. Refer to the steps for specific types of changes below.

### Change a Document

1. Change the document's content as necessary
2. Update frontmatter if applicable
3. Ensure all your changes conform to the format of [document source files](/articles/documentation.html#document-source-files)

### Add an Image

1. Create the new image file, ensuring the file conforms to the format of [image source files](/articles/documentation.html#image-source-files)
2. Optimize the image file for the web
3. Add the new image file
4. Reference the image file from a document

### Remove a Document

1. Remove the document file
2. Remove its entry from the [navigation tree](/articles/documentation.html#navigation)
3. Identify the image files referenced by the document, and remove each file unless it is referenced by other documents (which is rare)

### Add a Document

1. Add the new document file, ensuring it conforms to the format of [document source files](/articles/documentation.html#document-source-files)
2. Add an entry for the new document to the [navigation tree](/articles/documentation.html#navigation)

## 3. Confirm Your Changes

Every markdown implementation is a unique snowflake, so please **build the documentation and confirm your changes appear as expected before submitting them for review**. Also ensure your changes conform to the [documentation style guide](/articles/documentation-style-guide.html).

The following example demonstrates how to start a development server, which will re-build the docs each time you make a change.

```bash
$ cd docs && bundle
$ bin/middleman
```

Open the URL displayed in the output to view the built documentation.

## 4. Submit a Pull Request

After building the docs and confirming your changes, you can submit the changes as a pull request. Follow the same process used for [contributing code](/articles/contribute-code.html).
