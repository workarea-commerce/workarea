---
title: Documentation
created_at: 2018/12/10
excerpt: Workarea documentation is managed and versioned with the platform source code
---

# Documentation

Workarea documentation is managed and versioned with the platform source code.

## Published Documentation

Documentation is published automatically each time a new version of the platform is released. Beginning with Workarea 3.3, each major and minor version of the platform has its own documentation.

## Documentation Build System

A documentation build system builds the published documentation from the documentation sources that are included within each distribution of the platform.

The build system is based on [the Middleman static site generator](https://middlemanapp.com). The build system and documentation sources are located at _/docs_ within the Workarea source.

### Navigation

The build system includes [Middleman-NavTree](https://github.com/bryanbraun/middleman-navtree) for constructing navigation. The YAML file at the path _docs/data/articles.yml_ declares a tree representing the relationships of the platform article documents.

### Search

The build system includes [Middleman::Search](https://github.com/manastech/middleman-search) to provide search functionality.

This features requires each document to specify frontmatter for use in the search index. See [Document Source Files](#document-source-files) below.

## Documentation Sources

Within Workarea's _/doc_ directory, documentation source files and files that make up the build system are organized according to the [Middleman directory structure](https://middlemanapp.com/basics/directory-structure/).

### Image Source Files

Image source files are PNG or JPG files whose pathnames match the following pattern:

_docs/source/images/\*.{png,jpg}_

Words within filenames are separated with paths since the filenames are used in published URLs.

### Document Source Files

The pathnames of document source files match the following pattern:

_docs/source/{articles,release-notes}/\*.html.md_

Words within filenames are separated with paths since the filenames are used in published URLs.

The format of these documents is proprietary to the build system.

Each file begins with [YAML frontmatter](https://middlemanapp.com/basics/frontmatter/#yaml-frontmatter), which declares a title and excerpt used for search functionality. Adding a `created_at` entry to the frontmatter will allow the article to display within the Recent Articles section of the main documentation navigation. This date should be in `YYYY/MM/DD` format. 

Following the frontmatter is [Redcarpet](https://github.com/vmg/redcarpet) markdown with the `:tables`, `:no_intra_emphasis`, and `:fenced_code_blocks` extensions enabled.
