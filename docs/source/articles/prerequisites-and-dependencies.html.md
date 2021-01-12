---
title: Prerequisites & Dependencies
created_at: 2018/10/15
excerpt: The Workarea platform stands on the shoulders of many other software projects. Workarea's training and support materials focus on Workarea software and do not teach the specifics of Workarea's dependencies. However, this "prerequisite" knowledge is covere
---

# Prerequisites & Dependencies

The Workarea platform stands on the shoulders of many other software projects. Workarea's training and support materials focus on Workarea software and do not teach the specifics of Workarea's dependencies. However, this "prerequisite" knowledge is covered in depth by many other resources. In this guide, I introduce Workarea's most notable dependencies and provide links to resources that cover each.

## Help from the Workarea Community

While studying these topics, you may need to reach out for help. In addition to the usual places ([Google](https://www.google.com/), [Stack Overflow](http://stackoverflow.com/)), consider jumping on the [Workarea Slack](https://workarea-community.slack.com), where developers who have experience with Workarea applications will have the opportunity to help you.

## Critical Paths

For those looking for the short list(s), I've listed below the critical paths for back end and front end specialists.

### Back End

- [Ruby language](https://www.ruby-lang.org/en/) and [object oriented programming in Ruby](http://www.poodr.com/)
- [Ruby on Rails web framework](http://rubyonrails.org/)
- [Sidekiq background jobs](http://sidekiq.org/)
- [MongoDB document database](https://www.mongodb.org/) and [Mongoid object-document mapper](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/)
- [Elasticsearch full text search engine](https://www.elastic.co/products/elasticsearch) and [Elasticsearch libraries for Rails applications](https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-persistence)

### Front End

- [Ruby language](https://www.ruby-lang.org/en/)
- [Ruby on Rails web framework](http://rubyonrails.org/)
- [Haml templates](http://haml.info/)
- [SCSS stylesheets](http://sass-lang.com/)
- [BEM-based UI components](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/)
- [lodash utility library](https://lodash.com/)
- [jQuery DOM manipulation and ajax library](https://jquery.com/)

Continue reading for a deeper dive into Workarea's dependencies.

## Fundamentals

Let's start with some fundamentals.

### Operating System & Shell

Although it may be possible to develop Workarea applications on Windows, Workarea is hosted on and designed for use on Unix operating systems (including macOS). The <dfn>shell</dfn> is the program that passes commands from your keyboard to the operating system, and is also known as the <dfn>command line interface</dfn>, or <dfn>CLI</dfn>, for the OS. Many Workarea features depend on familiarity with the shell.

[The Command Line Crash Course](http://cli.learncodethehardway.org/book/) and [LinuxCommand.org](http://linuxcommand.org/) are online tutorials that present increasingly complex shell concepts while encouraging you to follow along. The material from LinuxCommand.org has also been developed into an ebook that's available [from the author](http://linuxcommand.org/tlcl.php) and [from No Starch Press](https://www.nostarch.com/tlcl.htm).

### Git

[Git](https://git-scm.com/) is the version control system used to manage Workarea source code and is the VCS you will most likely use to manage your application source code as well.

If you're completely new to Git, try it out interactively with [Try Git](https://try.github.io/levels/1/challenges/1). The [project's website](https://git-scm.com/) provides full API documentation for the command line interface and provides information about [graphical applications](https://git-scm.com/downloads/guis) for working with Git.

The site also provides downloads of the book [Pro Git](https://git-scm.com/book/en/v2), a easily digestible introduction to using Git. The book is also available [from Apress](http://www.apress.com/9781484200773).

## Ruby & Rails

Ruby and Rails are at the heart of Workarea, both technologically and philosophically. Both value developer happiness and productivity, two design principles that guide the development of the Workarea platform.

### Ruby Language

The predominant programming language in Workarea is [Ruby](https://www.ruby-lang.org/en/), a general purpose programming language used primarily for web applications due to the success of Ruby on Rails, which I cover below. While known chiefly as an object-oriented language, Ruby also provides strong support for the functional programming paradigm and is often used procedurally as a scripting language. Ruby's reader-friendly syntax, supportive community, and expansive standard library make it a favorite among developers.

Those new to Ruby can learn it interactively at [Try Ruby](http://tryruby.org/levels/1/challenges/0). Beyond that, check out [Programming Ruby](https://pragprog.com/book/ruby4/programming-ruby-1-9-2-0), also known as <dfn>The Pickaxe</dfn>. The book was the seminal English language work on Ruby. It provides a complete tutorial and reference for the language and is updated regularly by its original author and publisher. For a more whimsical explanation of the language, check out the ebook [Why's (Poignant) Guide to Ruby](http://poignant.guide/), a community favorite. Or, if you're an experienced programmer coming from another language, you may want to consult O'Reilly's [The Ruby Programming Language](http://shop.oreilly.com/product/9780596516178.do), co-authored by Yukihiro Matsumoto (Matz), the creator of Ruby.

Ruby's [official documentation](http://ruby-doc.org/) covers Ruby Core as well as the Standard Library, a collection of "blessed" libraries that ship with Ruby. The Ruby [project website](https://www.ruby-lang.org/en/) links to many other Ruby resources.

I'd also like to note that the Rails web framework includes [Active Support Core Extensions](http://edgeguides.rubyonrails.org/active_support_core_extensions.html) which extend many of Ruby's classes with additional useful methods. Many of these methods are used heavily in Workarea.

### Ruby Version Management

Ruby version managers exist to (1) install ruby versions and (2) change ruby versions. You will likely need many versions of Ruby installed to work on multiple applications that were developed at different points in time.

Workarea developers generally use [rbenv](https://github.com/rbenv/rbenv) + [ruby-build](https://github.com/rbenv/ruby-build) for this purpose. Other popular choices are [chruby](https://github.com/postmodern/chruby) + [ruby-install](https://github.com/postmodern/ruby-install) or [rvm](https://rvm.io/). Refer to each project's documentation to see how the tool installs and switches between different ruby versions.

### Ruby Programming

Ruby is often used for two different types of programming, scripting and applications. While scripts are typically written procedurally, applications tend to follow object-oriented design principles in order to manage complexity. For a primer on object-oriented design in Ruby, I highly recommend [Practical Object-Oriented Design in Ruby](http://www.poodr.com/), aka <dfn>POODR</dfn>. Sandi Metz leverages her decades of programming experience to bring object-orientation to life with clear examples using idomatic Ruby.

Central to the long term maintenance of applications is <dfn>refactoring</dfn>, restructuring software without changing its observable behavior. [Refactoring: Ruby Edition](http://martinfowler.com/books/refactoringRubyEd.html) is a rewrite of Martin Fowler's classic text on refactoring, this time with code examples in Ruby.

### Rails

[Ruby on Rails](http://rubyonrails.org/) is the de facto standard web framework for Ruby. Rails' [design principles](http://rubyonrails.org/doctrine/) of developer happiness and productivity were inspired by Ruby. Workarea builds heavily on Rails, both technologically and philosophically.

If you're new to Rails, get started with one of many Rails tutorials. The book [Agile Web Development with Rails](https://pragprog.com/book/rails4/agile-web-development-with-rails-4) is one such tutorial and was originally written by David Heinemeier Hansson (DHH), the creator of Rails. The book is now maintained by Sam Ruby under the same publisher and is diligently updated for each new version of Rails.

Next move on to the [Ruby on Rails Guides](http://guides.rubyonrails.org/), which are maintened by the Rails team and community, and cover the different aspects of Rails in greater depth. Workarea tries to deviate as little as possible from Rails, but one difference is the use of Mongoid instead of Active Record. I explain Mongoid below, but mention it here because Active Record is covered prominently in the Rails guides. Fortunately, Mongoid copies the API of Active Record, so if you have an existing knowledge of Active Record, it will translate well to Mongoid.

Finally, for a class and method level reference, refer to the [Rails API Documentation](http://api.rubyonrails.org/).

### Testing

Automated testing is core to the Ruby community and to Workarea. Workarea uses several testing tools, some of which are listed below.

| Project | Description |
| --- | --- |
| [Minitest](https://github.com/seattlerb/minitest) | Testing framework for Ruby including test runner, assertion library, and mocking library |
| [Capybara](https://github.com/jnicklas/capybara) | Acceptance testing library providing a DSL to drive a headless browser |
| [WebMock](https://github.com/bblimke/webmock) | A library for stubbing and setting expectations on HTTP requests in Ruby |
| [vcr](https://github.com/vcr/vcr) | Library for recording and replaying HTTP requests and responses |

### Additional Dependencies

The following table lists other notable libraries utilized by Workarea.

| Project | Usage |
| --- | --- |
| [Sidekiq](https://github.com/mperham/sidekiq) | Process potentially expensive jobs in the background |
| [Sidekiq-Cron](https://github.com/ondrejbartas/sidekiq-cron) | Schedule Sidekiq jobs |
| [Dragonfly](https://markevans.github.io/dragonfly/) | Store files and process images using libvips and ImageMagick |
| [Active Merchant](https://github.com/activemerchant/active_merchant) | Integrate with a variety of payment gateways |
| [I18n.js](https://github.com/fnando/i18n-js) | Provide Ruby I18n translations in JavaScript |
| [JsRoutes](https://github.com/railsware/js-routes) | Provide Rails named routes in JavaScript |
| [Kaminari](https://github.com/amatsuda/kaminari) | Paginate collections |
| [Local Time](https://github.com/basecamp/local_time) | Display times in a user's local time zone |
| [Predictor](https://github.com/Pathgather/predictor) | Produce product recommendations |
| [Rack::Attack!!!](https://github.com/kickstarter/rack-attack) | Block and throttle abusive requests |

Ruby libraries for interacting with databases are covered below.

## Databases

Workarea applications depend on three different document-based (NoSQL) databases: MongoDB, Elasticsearch, and Redis. Each of the databases uses a client/server architecture, and Workarea provides a Ruby client for each database. Resources for the three databases and their Ruby drivers are provided below.

### MongoDB & Mongoid

[MongoDB](https://www.mongodb.org/) is used as the primary data store in Workarea applications. MongoDB is a NoSQL database designed for modern web applications. It is designed primarily for developers rather than analysts and employs an intuitive data model based on documents rather than tables. MongoDB utilizes a client/server architecture where programming language APIs are used to communicate with the server via BSON, a binary representation of JSON (with proprietary extensions).

Workarea applications typically run on the latest version of the database, currently v3.2.

While there is a low level Ruby driver for MongoDB, Workarea uses [Mongoid](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/), an <dfn>Object-Document Mapper</dfn>, or <dfn>ODM</dfn>. Mongoid provides an API that is purposefully similar to [Active Record](http://guides.rubyonrails.org/active_record_basics.html), the library used to persist models in Rails applications using relational databases. If you have any familiarity with Active Record, that knowledge should transfer directly to Mongoid.

If you're new to MongoDB, I recommend the book [MongoDB in Action, Second Edition](https://www.manning.com/books/mongodb-in-action-second-edition), written by a former employee of [MongoDB, Inc.](https://www.mongodb.com/), the corporate sponsor and developer of MongoDB. The book introduces Mongo and compares it to other databases before explaining how to develop a Mongo application using the MongoDB shell and MongoDB Ruby driver. The second edition was updated to cover MongoDB version 3.0.

MongoDB Inc. also provides free online courses at [MongoDB University](https://university.mongodb.com/). While they don't teach a Ruby-specific course, all the Mongo drivers have a similar API, so knowledge of one will transfer to any other.

The following learning resources are available directly from MongoDB:

- [MongoDB Manual](https://docs.mongodb.org/manual/)
- [Getting Started Guide](https://docs.mongodb.org/getting-started/shell/)
- [Ruby Driver Tutorial](https://docs.mongodb.org/ecosystem/drivers/ruby/)
- [Mongoid Tutorial](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/)

Workarea also uses the following libraries to extend Mongoid:

| Project | Extension to Mongoid |
| --- | --- |
| [Money-Rails](https://github.com/RubyMoney/money-rails) | `Money` data type |
| [Mongoid::ActiveMerchant](https://github.com/bencrouse/mongoid-active_merchant) | `ActiveMerchant::Billing::Response` data type |
| [Mongoid::AuditLog](https://github.com/bencrouse/mongoid-audit_log) | Audit logging of Mongoid documents |
| [mongoid-paranoia](https://github.com/haihappen/mongoid-paranoia) | "Soft" deletion of Mongoid documents |
| [mongoid-tree](https://github.com/benedikt/mongoid-tree) | Tree structure |

### Elasticsearch

[Elasticsearch](https://www.elastic.co/products/elasticsearch) is the full text search engine for Workarea applications. The project is built on top of Apache Lucene, a full text search engine library used to integrate search functionality into Java applications. Elasticsearch, also written in Java, hides the complexities of Lucene behind RESTful APIs. Elasticsearch clients use these APIs to communicate with Elasticsearch servers via JSON over HTTP.

Workarea uses Elasticsearch version 5.x. Workarea applications use a Ruby client to communicate with the Elasticsearch server.

If you're new to Elasticsearch there is no better resource than [Elasticsearch: The Definitive Guide](https://www.elastic.co/guide/en/elasticsearch/guide/current/index.html). This holistic and accessible book presents the technology and philosophy of Elasticsearch and is written and maintained by two trainers from [Elastic](https://www.elastic.co/), the corporate sponsor and developer of Elasticsearch. The book is also available from [O'Reilly Media](http://shop.oreilly.com/product/0636920028505.do).

Elastic also provides [in person trainings](https://www.elastic.co/training) at various locations for a fee.

The [Elasticsearch Reference (v5.0)](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/index.html) is a complete reference to the Elasticsearch RESTful APIs.

### Redis

Workarea also makes use of [Redis](http://redis.io/), an in-memory data structure store, used as a database and cache. Workarea applications use the [Ruby client library for Redis](https://github.com/redis/redis-rb) to communicate with a Redis server over the network via a proprietary protocol.

Due to its simplicity, there is little to learn about Redis. Refer to the [command reference](http://redis.io/commands) as needed to manipulate keys and values stored in Redis.

## Front End

### HTML & CSS

Workarea uses a modular component library to compose its UIs. Front end developers will benefit from familiarity with a UI component library, such as [Bootstrap](http://getbootstrap.com/components/). Workarea uses [style guides](/articles/style-guides.html) to document and unit test its UI components. Unit testing of front end components is not a well adopted practice among front end developers. If this concept is new to you, review the [test suite for Normalize.css](https://github.com/necolas/normalize.css/blob/master/test.html) ([view the rendered HTML](http://htmlpreview.github.io/?https://github.com/necolas/normalize.css/blob/master/test.html)), which demonstrates the idea well.

Another important concept of the Workarea front end is [BEM](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/), which stands for <dfn>Block, Element, Modifier</dfn>. Workarea uses the BEM methodology for naming and structuring HTML and CSS. BEM and other concepts are explained in [CSS Guidelines](http://cssguidelin.es/), which Workarea follows as a style guide.

Front end developers should also familiarize themselves with the following HTML/CSS dependencies:

| Project | Description |
| --- | --- |
| [Haml](http://haml.info/) | The server-side templating language responsible for rendering HTML |
| [Sass (SCSS)](http://sass-lang.com/) | The stylesheet language used to produce CSS |
| [Normalize.css](https://necolas.github.io/normalize.css/) | A library to normalize CSS across browsers (similar to a CSS reset), version 3.x |

### JavaScript

Workarea depends on a variety of JavaScript libraries, most notably the following:

| Project | Description |
| --- | --- |
| [lodash](https://lodash.com/) | JavaScript's missing standard library which provides cross-browser implementations of `map`, `reduce`, and similar functions, version 3.x |
| [jQuery](https://jquery.com/) | The de facto standard libarary for DOM manipulations and ajax, version 1.11.x |
| [jQuery&nbsp;UI](https://jqueryui.com/) | Extensible UI widget library, version 1.11.x |
| [jQuery&nbsp;Validation&nbsp;Plugin](http://jqueryvalidation.org/) | Library for client-side validation |
| [Feature.js](http://featurejs.com/) | Feature detection library, version 1.0.1 |
| [Teaspoon](https://github.com/modeset/teaspoon) | JavaScript test runner for Rails applications |
| [Mocha](https://mochajs.org/) | JavaScript testing framework |
| [Chai](http://chaijs.com/) | JavaScript assertion library |
