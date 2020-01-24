module Sidekiq
  # A plugin for +Sidekiq+ that enables automatic job enqueuing via
  # Rails callback methods. Mix +Sidekiq::Callbacks+ into your model to
  # enable this feature on any class that defines +run_callbacks+.
  module Callbacks
    extend ActiveSupport::Concern
    class InvalidConfiguration < RuntimeError; end

    class << self
      # The list of workers that perform Sidekiq callbacks. Used for checking
      # whether one of them need to be fired off after a callback happens.
      #
      # @private
      # @return [Array<Class>]
      #
      def workers
        caching_classes? ? workers_list : workers_list.map(&:constantize)
      end

      # Add a {Class} to the list of workers to check when running callbacks.
      #
      # @private
      # @param [Class] worker
      #
      def add_worker(klass)
        if caching_classes?
          workers_list << klass
        elsif !workers_list.include?(klass.name)
          workers_list << klass.name
        end
      end

      # Whether Rails is caching classes, which matters when checking workers to
      # run by comparing the worker's configuration with the model running the
      # callback.
      #
      # When we aren't caching classes, we need to use the fully qualified
      # constant name to decide since the classes could have been reloaded due
      # to code changes.
      #
      # @return [Boolean]
      #
      def caching_classes?
        ::Rails.application.config.cache_classes
      end

      # Convenience reference to the tracked list of workers in the Rails config
      #
      # @private
      # @return [Array<String,Class>]
      #
      def workers_list
        config = ::Rails.application.config
        config.sidekiq_callbacks_workers = [] unless config.respond_to?(:sidekiq_callbacks_workers)
        config.sidekiq_callbacks_workers
      end

      # Permanently or temporarily enable callback workers. If
      # no workers are given, it will enable all callback
      # workers during the execution of the block or globally if no
      # block is given. If a block and workers are given, workers
      # provided will only be enable during the execution of the
      # block. Callback workers already enabled will continue to be
      # enabled during block execution.
      #
      # @example permanently enable all workers
      #   Sidekiq::Callbacks.enable
      #
      # @example temporarily enable all workers
      #   Sidekiq::Callbacks.enable do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @example permanently enable specific workers
      #   Sidekiq::Callbacks.enable(IndexProductBrowse, IndexContent)
      #
      # @example temporarily enable specific workers
      #   Sidekiq::Callbacks.enable(IndexContent) do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @overload enable(worker, ...)
      #   @param [Object] worker  A worker to enable
      #   @param [Object] ...     Any number of workers to enable
      #
      # @yield code to be executed during temporarily enabling of workers
      # @return nil or result of block if provided
      #
      def enable(*workers, &block)
        set_workers(workers, :enable, &block)
      end

      # Permanently or temporarily disable callback workers. If
      # no workers are given, it will disable all callback
      # workers during the execution of the block or globally if no
      # block is given. If a block and workers are given, workers
      # provided will only be disabled during the execution of the block.
      #
      # @example permanently disable all workers
      #   Sidekiq::Callbacks.disable
      #
      # @example temporarily disable all workers
      #   Sidekiq::Callbacks.disable do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @example permanently disable specific workers
      #   Sidekiq::Callbacks.disable(IndexProductBrowse, IndexContent)
      #
      # @example temporarily disable specific workers
      #   Sidekiq::Callbacks.disable(IndexContent) do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @overload disable(worker, ...)
      #   @param [Object] worker  A worker to disable
      #   @param [Object] ...     Any number of workers to disable
      #
      # @yield code to be executed during temporarily disabling of workers
      # @return nil or result of block if provided
      #
      def disable(*workers, &block)
        set_workers(workers, :disable, &block)
      end

      # Permanently or temporarily inline callback workers. If
      # no workers are given, it will inline all callback
      # workers during the execution of the block or globally if no
      # block is given. If a block and workers are given, workers
      # provided will only be inline during the execution of the
      # block. Callback workers already inlined will continue to be
      # inlined during block execution.
      #
      # @example permanently inline all workers
      #   Sidekiq::Callbacks.inline
      #
      # @example temporarily inline all workers
      #   Sidekiq::Callbacks.inline do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @example permanently inline specific workers
      #   Sidekiq::Callbacks.inline(IndexProductBrowse, IndexContent)
      #
      # @example temporarily inline specific workers
      #   Sidekiq::Callbacks.inline(IndexContent) do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @overload inline(worker, ...)
      #   @param [Object] worker  A worker to inline
      #   @param [Object] ...     Any number of workers to inline
      #
      # @yield code to be executed during temporarily enabling of workers
      # @return nil or result of block if provided
      #
      def inline(*workers, &block)
        set_workers(workers, :inline, &block)
      end

      # Permanently or temporarily inline callback workers. If
      # no workers are given, it will inline all callback
      # workers during the execution of the block or globally if no
      # block is given. If a block and workers are given, workers
      # provided will only be async during the execution of the block.
      #
      # @example permanently inline all workers
      #   Sidekiq::Callbacks.inline
      #
      # @example temporarily async all workers
      #   Sidekiq::Callbacks.async do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @example permanently async specific workers
      #   Sidekiq::Callbacks.async(IndexProductBrowse, IndexContent)
      #
      # @example temporarily async specific workers
      #   Sidekiq::Callbacks.async(IndexContent) do
      #     Content.create!(name: 'Foo')
      #   end
      #
      # @overload async(worker, ...)
      #   @param [Object] worker  A worker to set async
      #   @param [Object] ...     Any number of workers to set async
      #
      # @yield code to be executed during temporarily asyncing of workers
      # @return nil or result of block if provided
      #
      def async(*workers, &block)
        set_workers(workers, :async, &block)
      end

      # This method is run on boot to ensure a valid configuration of callback
      # workers. It will raise a Sidekiq::Callbacks::InvalidConfiguration if it
      # finds a problem.
      #
      def assert_valid_config!
        Sidekiq::Callbacks.workers.each do |worker|
          if (worker.enqueue_on.values.flatten & [:find, 'find']).any?
            raise(
              InvalidConfiguration,
              "For performance reasons, Sidekiq::Callbacks do not support the `find` callback."
            )
          end
        end
      end

      private

      def set_workers(workers, action)
        workers = Sidekiq::Callbacks.workers if workers.blank?

        if !block_given?
          workers.each(&action)
        else
          worker_state = workers.reduce({}) do |memo, worker|
            memo[worker] = [worker.enabled?, worker.inlined?]
            memo
          end

          workers.each(&action)

          begin
            result = yield

          ensure
            workers.each do |worker|
              worker.enabled = worker_state[worker].first
              worker.inlined = worker_state[worker].second
            end
          end

          result
        end
      end
    end

    def run_callbacks(kind, *)
      result = super
      _enqueue_callback_workers(kind) if result != false && kind != :find
      result
    end

    private

    def _enqueue_callback_workers(kind)
      Sidekiq::Callbacks.workers.select(&:enabled?).each do |worker|
        worker.callbacks.each do |klass, callbacks|
          if _perform_callback_worker?(klass, callbacks, kind, worker)
            args = worker.find_callback_args(self)

            if worker.inlined?
              worker.new.perform(*args)
            else
              worker.perform_async(*args)
            end
          end
        end
      end
    end

    def _perform_callback_worker?(model_class, callbacks, kind, worker_class)
      _is_a_callback_type_match?(model_class) &&
        Array(callbacks).include?(kind) &&
        worker_class.perform_callback?(self)
    end

    def _is_a_callback_type_match?(model_class)
      return is_a?(model_class) if Sidekiq::Callbacks.caching_classes?

      # This is a funny way of doing the same check as `is_a?`.
      #
      # Consider this example from a Sidekiq::CallbacksWorker:
      #   `enqueue_on: { Catalog::Product => :create }`
      #
      # On app boot, we get a reference to the Catalog::Product constant. If in
      # development reloading mode, something causes that constant to get reloaded
      # we end up with the same constant with a different `object_id`. This
      # happens because Rails undefines the constant and creates it again.
      # Because these `object_id`s are different, the `is_a?` check will fail in
      # subsequent checks to see if this worker should fire.
      #
      # This hack uses string comparison to alleviate.
      #
      @_callbacks_ancestors_cache ||= self.class.ancestors.map(&:name)
      @_callbacks_ancestors_cache.include?(model_class.name)
    end
  end
end
