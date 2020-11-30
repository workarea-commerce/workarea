---
title: Workers
created_at: 2018/07/31
excerpt: Workarea applications use Sidekiq as a job queuing backend to perform units of work asynchronously in the background. These jobs, which include search indexing, cache busting, and cleanup of expired data, are defined as workers. Workarea workers build
---

# Workers

Workarea applications use [Sidekiq](https://github.com/mperham/sidekiq) as a job queuing backend to perform units of work asynchronously in the background. These jobs, which include search indexing, cache busting, and cleanup of expired data, are defined as <dfn>workers</dfn>. Workarea workers build on Sidekiq's worker concept and are typically enqueued on a schedule or in response to callbacks on [application documents](/articles/application-document.html).

## Sidekiq Workers

Sidekiq workers are classes that include `Sidekiq::Worker` ([docs](http://www.rubydoc.info/github/mperham/sidekiq/Sidekiq/Worker)) and represent units of work that may be performed immediately (inline) or may be enqueued to be performed in the background (async). A Sidekiq worker must implement the `perform` instance method, whose signature will vary depending on how the worker is intended to be used. The example below is intended to be called with a hash of attributes that will be used to create a model instance.

```ruby
class CreateCategory
  include Sidekiq::Worker

  def perform(attributes)
    Workarea::Catalog::Category.create!(attributes)
  end
end

# Run inline
CreateCategory.new.perform(name: 'Shirts')

# Run async (enqueue)
CreateCategory.perform_async(name: 'Shirts')
```

### Inline Sidekiq

When `Sidekiq::Testing.inline!` is `true`, the inline and async examples above behave the same. The async example is run synchronously and is not enqueued into Sidekiq.

In many cases, a Sidekiq process is not running in a development environment, so Workarea applications include the following configuration which defaults `Sidekiq::Testing.inline!` to `true` in the Development environment.

```ruby
# your_app/config/environments/development.rb

Rails.application.configure do
  # Run Sidekiq tasks synchronously so that Sidekiq is not required in Development
  require 'sidekiq/testing/inline'

  # ...
end
```

### Worker Options & Queues

Within a worker class definition, the `sidekiq_options` method declares [options for that worker](https://github.com/mperham/sidekiq/wiki/Advanced-Options#workers). Sidekiq worker options include `retry`, to set the worker's retry behavior, and `queue`, to enqueue the worker into a specific [queue](https://github.com/mperham/sidekiq/wiki/Advanced-Options#queues).

Since Workarea 3.5.0, Workarea configures 5 Sidekiq queues: _releases_, _high_, _default_, _low_, and _mailers_.

## Workarea Workers

Workarea workers are simply Sidekiq workers defined within the `Workarea` namespace. Workers are defined within Workarea engines and applications at the path _app/workers/workarea/worker\_name.rb_.

Some Workarea workers are re-used outside the context of Sidekiq and therefore have additional convenience methods. This is particularly true of workers used to index documents into Elasticsearch. The worker shown below includes two public class methods in addition to the conventional `perform` instance method.

```ruby
module Workarea
  class BulkIndexProducts
    include Sidekiq::Worker
    # ...

    class << self
      def perform(ids = Catalog::Product.pluck(:id))
        # ...
      end

      def perform_by_models(products)
        # ...
      end
    end

    def perform(ids)
      self.class.perform(ids)
    end
  end
end
```

`BulkIndexProducts.perform` accepts a collection of product ids, defaulting to **all** product ids if a collection is not provided. The `perform` instance method used by Sidekiq delegates to this method. `BulkIndexProducts.perform_by_models` accepts a collection of product model instances instead of a collection of ids.

In the example below, the `perform` class method expects a model instance instead of an id. This is a common pattern among workers that operate on a model instance.

```ruby
module Workarea
  class IndexAdminSearch
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    #...

    def self.perform(model)
      # ...
    end

    def perform(class_name, id)
      model = class_name.constantize.find_or_initialize_by(id: id)
      self.class.perform(model)
    end
  end
end
```

Again, the `perform` instance method uses the `perform` class method within its implementation.

These additional APIs are useful for a variety of <abbr title="command-line interface">CLI</abbr> and scripting use cases, such as rake tasks used to re-index Elasticsearch.

## Sidekiq Cron Job

Many Workarea workers are used for cleanup and other recurring tasks and are enqueued on a fixed schedule. Within an engine or application, each instance of `Sidekiq::Cron::Job` ([docs](http://www.rubydoc.info/gems/sidekiq-cron/Sidekiq/Cron/Job), also see [Sidekiq-Cron](https://github.com/ondrejbartas/sidekiq-cron)) schedules a worker to be enqueued on a schedule, which is declared using cron notation.

Cron jobs are declared within an initializer like the one shown below.

```ruby
# workarea-core/config/initializers/05_scheduled_jobs.rb

Sidekiq::Cron::Job.create(
  name: 'Workarea::AnalyticsWeeklyUpdate',
  klass: 'Workarea::AnalyticsWeeklyUpdate',
  cron: '0 0 * * 0',
  queue: 'high'
)

Sidekiq::Cron::Job.create(
  name: 'Workarea::AnalyticsDailyUpdate',
  klass: 'Workarea::AnalyticsDailyUpdate',
  cron: '0 0 * * *',
  queue: 'high'
)

Sidekiq::Cron::Job.create(
  name: 'Workarea::CleanInventoryTransactions',
  klass: 'Workarea::CleanInventoryTransactions',
  cron: '0 5 * * *',
  queue: 'low'
)

# ...
```

### Cron Job Arguments

Workers run as cron jobs typically do not make use of arguments, so the `perform` method of these workers usually takes one of the following forms.

```ruby
# workarea-core/app/workers/workarea/analytics_daily_update.rb

module Workarea
  class AnalyticsDailyUpdate
    include Sidekiq::Worker

    def perform(*)
      Analytics::TimeSeries.reset_for_today!
    end
  end
end

# workarea-core/app/workers/workarea/clean_inventory_transactions.rb

module Workarea
  class CleanInventoryTransactions
    include Sidekiq::Worker

    def perform(*args)
      Inventory::Transaction.expired.delete_all
    end
  end
end
```

## Callbacks Worker

Instead of binding to a schedule, many workers are run or enqueued in response to callbacks representing the life cycles of [application documents](/articles/application-document.html) or other objects. These workers are referred to as <dfn>callbacks workers</dfn>.

Callbacks workers include the module `Sidekiq::CallbacksWorker`, which is a Workarea extension to Sidekiq. Among other things, this module provides the `enqueue_on` Sidekiq worker option, which allows a worker to register itself to be run or enqueued in response to any [ActiveSupport callback](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html).

ActiveSupport defines <dfn>callbacks</dfn> as "code hooks that are run at key points in an object's life cycle". In practice, callbacks workers are primarily concerned with [Mongoid callbacks](https://docs.mongodb.com/ruby-driver/master/tutorials/6.1.0/mongoid-callbacks/) representing changes to an application document, such as `save` and `destroy`. Some custom callbacks are also important, such as the `place` callback on `Workarea::Order`.

### Declaring Callbacks & Arguments

Callbacks workers use the `enqueue_on` option to declare which callbacks on which classes will cause the worker to be run or enqueued. The `with` sub option may be used to declare the arguments that will be passed to `perform` when the worker is run. Furthermore, the `ignore_if` and `only_if` options may be used to conditionally run/enqueue the worker.

In the simplest case, a worker declares a single callback on a single class. When run, `perform` receives the `id` of the instance that triggered the callback. The following worker will be run or enqueued after instances of `Navigation::Taxon` are saved.

```ruby
module Workarea
  class BustNavigationCache
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Navigation::Taxon => :save }

    def perform(id)
      # ...
    end
  end
end
```

The following code listing shows examples that declare multiple classes and callbacks.

```ruby
sidekiq_options enqueue_on: { Pricing::Discount => [:save, :destroy] }

sidekiq_options(
  enqueue_on: {
    Inventory::Sku => [:save, :destroy],
    Pricing::Sku => [:save, :destroy]
  }
)

sidekiq_options(
  enqueue_on: {
    Order => [:create, :place, :destroy],
    Fulfillment => [:update]
  }
)
```

The following examples provide a value to `with` to declare the arguments to be passed to `perform` when the worker is run. The value of `with` is a lambda that will be evaluated in the context of the object that triggered the callback (using `instance_exec`). Note how the signature of `perform` changes in each example to match the array returned by the `with` lambda.

```ruby
# passes the release changes in addition to the id
module Workarea
  class UpdatePaymentProfileEmail
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        User => :update,
        with: -> { [id, changes] }
      }
    )

    def perform(id, changes)
      # ...
    end
  end
end

# passes the changes only (no id)
module Workarea
  class IndexCategoryChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Category => :save,
        with: -> { [changes] }
      },
    )

    def perform(changes)
      # ...
    end
  end
end

# passes the parent id since the document
# that triggered the callback is embedded
module Workarea
  class IndexProductChildren
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Variant => [:save, :destroy],
        Catalog::ProductImage => [:save, :destroy],
        with: -> { [_parent.id.to_s] }
      }
    )

    def perform(id)
      # ...
    end
  end
end
```

The following example demonstrates the use of the `ignore_if` option to conditionally skip the enqueuing of the worker. Like `with`, the value of `ignore_if` is a lambda that will be evaluated in the context of the object that triggered the callback (using `instance_exec`). The following worker ensures a search model was created and should be indexed before running or enqueuing the worker.

```ruby
module Workarea
  class IndexAdminSearch
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      queue: 'low',
      unique: :until_executing,
      enqueue_on: {
        ApplicationDocument => [:save, :touch, :destroy],
        with: -> { [self.class.name, id] },
        ignore_if: -> { !IndexAdminSearch.should_enqueue?(self) }
      }
    )

    def self.should_enqueue?(model)
      search_model = Search::Admin.for(model)
      search_model.present? && search_model.should_be_indexed?
    end

    # ...
  end
end
```

For parity, Workarea 3.1 adds the `only_if` option. The lambda assigned to this option must return a truthy value in order for the worker to run/enqueue. The following example re-writes the previous example using `only_if` instead of `ignore_if`.

```ruby
module Workarea
  class IndexAdminSearch
    # ...

    sidekiq_options(
      # ...

      enqueue_on: {
	# ...

        only_if: -> { IndexAdminSearch.should_enqueue?(self) }
      }
    )

    # ...
  end
end
```

You can use the `callbacks` and `enqueue_on` class methods to expose the current configuration of a particular callbacks worker.

```ruby
Workarea::IndexSearchCustomizations.callbacks
# => { Workarea::Search::Customization => [:save, :destroy] }

Workarea::IndexSkus.enqueue_on
# => {
# Workarea::Inventory::Sku => [:save, :destroy],
# Workarea::Pricing::Sku=>[:save, :destroy]
# }

Workarea::IndexSearchCustomizations.enqueue_on
# => {
# Workarea::Search::Customization => [:save, :destroy],
# :with => #<Proc:0x007… >
# }
```

### Callback Worker Timing

ActiveSupport callbacks are composed of a `:kind` and a `:name` and are displayed in the format `#{kind}_#{name}`, for example, `before_save`. As the examples above demonstrate, callbacks workers are concerned only with the callback _name_ and have no concept of a callback _kind_. This is because callbacks workers are always run or enqueued **after** all applicable ActiveSupport callbacks.

The following example demonstrates the timing of callbacks workers relative to ActiveSupport callbacks. The `Workarea::Widget` document has `before_save` and `after_save` Mongoid callbacks and `before_foo` and `after_foo` custom ActiveSupport callbacks. The `Workarea::FooBar` worker runs on `Widget#save`, and the `Workarea::BazQux` worker runs on `Widget#foo`. Creating a widget instance and invoking `foo` demonstrates that each worker is run **after** all applicable ActiveSupport callback blocks are finished executing.

```ruby
module Workarea
  class Widget
    include ApplicationDocument

    before_save do
      puts 'before_save callback'
    end

    after_save do
      puts 'after_save callback'
    end

    define_callbacks :foo

    set_callback :foo, :before do
      puts 'before_foo callback'
    end

    set_callback :foo, :after do
      puts 'after_foo callback'
    end

    def foo
      run_callbacks :foo do
        puts 'foo'
      end
    end
  end
end

module Workarea
  class FooBar
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Widget => [:save] }

    def perform(*)
      puts 'Run or enqueue FooBar worker'
    end
  end
end

module Workarea
  class BazQux
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Widget => [:foo] }

    def perform(*)
      puts 'Run or enqueue BazQux worker'
    end
  end
end

Sidekiq::Callbacks.inline do
  widget = Workarea::Widget.create!
  # before_save callback
  # after_save callback
  # Run or enqueue FooBar worker

  widget.foo
  # before_foo callback
  # foo
  # after_foo callback
  # Run or enqueue BazQux worker
end
```

### Disabling & Inlining Callbacks Workers

A <dfn>disabled</dfn> callbacks worker will not run or enqueue in response to callbacks. It may be run manually only (by creating an instance and calling its `perform` method). An <dfn>inlined</dfn> callbacks worker will bypass the Sidekiq queue and run synchronously in response to callbacks. This is true in all environments, even those with a running Sidekiq process. Disabled and inlined workers may be <dfn>enabled</dfn> and <dfn>asynced</dfn> to restore the default callbacks worker behavior.

The following APIs are used to disable, enable, inline, and async a callbacks worker and query its current status.

```ruby
FooBarWorker.enabled?
FooBarWorker.enable
FooBarWorker.disable

FooBarWorker.inlined?
FooBarWorker.inline
FooBarWorker.async
```

## Sidekiq Callbacks

The `Sidekiq::Callbacks` module provides class methods to manipulate collections of workers, allowing all or many workers to be enabled, disabled, inlined, or asynced permanently or temporarily.

These APIs allow for the following use cases:

- Disable workers that send email during a user account import
- Inline Elasticsearch indexing for requests where the changes should be reflected immediately
- Improve the performance of imports by disabling indexing and doing a bulk index at the end

### Enable

```ruby
# Enable all Sidekiq callbacks for the duration of the program
Sidekiq::Callbacks.enable

# Enable all Sidekiq callbacks for the duration of a block
Sidekiq::Callbacks.enable do
  # do something while Sidekiq callbacks are enabled
end

# Enable specific workers for the duration of the program
Sidekiq::Callbacks.enable(IndexFoo, IndexBar)

# Enable specific workers for the duration of a block
Sidekiq::Callbacks.enable(IndexFoo) do
  # do something while specific Sidekiq callbacks are enabled
end
```

### Disable

```ruby
# Disable all Sidekiq callbacks for the duration of the program
Sidekiq::Callbacks.disable

# Disable all Sidekiq callbacks for the duration of a block
Sidekiq::Callbacks.disable do
  # do something while Sidekiq callbacks are disabled
end

# Disable specific workers for the duration of the program
Sidekiq::Callbacks.disable(IndexFoo, IndexBar)

# Disable specific workers for the duration of a block
Sidekiq::Callbacks.disable(IndexFoo) do
  # do something while specific Sidekiq callbacks are disabled
end
```

### Inline

```ruby
# Inline all Sidekiq callbacks for the duration of the program
Sidekiq::Callbacks.inline

# Inline all Sidekiq callbacks for the duration of a block
Sidekiq::Callbacks.inline do
  # do something while Sidekiq callbacks are running inline
end

# Inline specific workers for the duration of the program
Sidekiq::Callbacks.inline(IndexFoo, IndexBar)

# Inline specific workers for the duration of a block
Sidekiq::Callbacks.inline(IndexFoo) do
  # do something while specific Sidekiq callbacks are running inline
end
```

### Async

```ruby
# Async all Sidekiq callbacks for the duration of the program
Sidekiq::Callbacks.async

# Async all Sidekiq callbacks for the duration of a block
Sidekiq::Callbacks.async do
  # do something while Sidekiq callbacks are running async
end

# Async specific workers for the duration of the program
Sidekiq::Callbacks.async(IndexFoo, IndexBar)

# Async specific workers for the duration of a block
Sidekiq::Callbacks.async(IndexFoo) do
  # do something while specific Sidekiq callbacks are running async
end
```

### Admin Application Controller Example

The Admin engine's application controller uses `Sidekiq::Callbacks.inline` to inline the `IndexAdminSearch` worker for the duration of the request. This allows administrators to make changes through the Admin UI and see the changes reflected immediately (on the following request) because the Admin search index is re-indexed inline rather than being enqueued.

```ruby
# workarea-admin/app/controllers/workarea/admin/application_controller.rb

module Workarea
  module Admin
    class ApplicationController < Workarea::ApplicationController
      # ...
      around_action :inline_search_indexing

      # ...
      private

      def inline_search_indexing
        Sidekiq::Callbacks.inline(IndexAdminSearch) { yield }
      end

      # ...
    end
  end
end
```

## Unique Jobs

Many Workarea workers, particularly those that index documents into Elasticsearch, are idempotent. It is undesirable to have multiple instances of an idempotent worker in the same Sidekiq queue since subsequent runs will duplicate work.

[SidekiqUniqueJobs](https://github.com/mhenrixon/sidekiq-unique-jobs) provides the `unique` Sidekiq worker option to allow a worker to enforce uniqueness.

The following worker uses the [unique until executing](https://github.com/mhenrixon/sidekiq-unique-jobs/blob/v4.0.18/README.md#until-executing) strategy to enforce uniqueness.

```ruby
# workarea-core/app/workers/workarea/bulk_index_products.rb

module Workarea
  class BulkIndexProducts
    include Sidekiq::Worker

    sidekiq_options unique: :until_executing

    # ...
  end
end
```

## Throttling

Some Workarea workers have the potential to be long running, resource intensive tasks that could cause congestion in the Sidekiq processes if too many are running simultaneously. For these scenarios, notably import and export tasks, it is ideal to limit the number of these jobs that are being run at the same time.

[Sidekiq Throttled](https://github.com/sensortower/sidekiq-throttled) provides a way to limit concurrency of this type of Sidekiq job.

The following worker uses the `sidekiq_throttle` class method to define the worker's rules around concurrency ensuring that only one export worker will be run at a time.

```ruby
# workarea-core/app/workers/workarea/process_export.rb

module Workarea
  class ProcessExport
    include Sidekiq::Worker
    include Sidekiq::Throttled::Worker

    # ....

    sidekiq_throttle(concurrency: { limit: 1 })

    def perform(id)
      # ...
    end
  end
end

```

It is important to note that throttling, as compared to uniqueness, does not affect when or if jobs are added to a Sidekiq queue. Instead, throttling a worker will only restrict the timing of workers being plucked from the queue for processing.
