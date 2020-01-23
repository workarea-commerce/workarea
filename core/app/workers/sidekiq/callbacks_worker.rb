module Sidekiq
  # Mixin for Sidekiq workers that enables the worker to be called via
  # Rails callback methods.
  module CallbacksWorker
    extend ActiveSupport::Concern

    included do
      thread_cattr_accessor :enabled, :inlined
      Sidekiq::Callbacks.add_worker(self)
    end

    class_methods do
      # @deprecated TODO remove this in v3.6
      def workers
        Sidekiq::Callbacks.workers
      end

      def enabled?
        enabled.nil? || !!enabled
      end

      def disabled?
        !enabled?
      end

      def enable
        self.enabled = true
      end

      def disable
        self.enabled = false
      end

      def inlined?
        !!inlined
      end

      def inline
        self.inlined = true
      end

      def async
        self.inlined = false
      end

      def enqueue_on
        get_sidekiq_options['enqueue_on'] ||
          get_sidekiq_options[:enqueue_on] ||
          {}
      end

      def callbacks
        enqueue_on.except(:with, 'with', :ignore_if, 'ignore_if', :only_if, 'only_if')
      end

      def find_callback_args(model)
        with = enqueue_on[:with] || enqueue_on['with']

        if with.present?
          model.instance_exec(&with)
        else
          [model.id.to_s]
        end
      end

      def perform_callback?(model)
        only_if = enqueue_on[:only_if] || enqueue_on['only_if']
        ignore_if = enqueue_on[:ignore_if] || enqueue_on['ignore_if']

        (only_if.blank? || !!model.instance_exec(&only_if)) &&
          (ignore_if.blank? || !model.instance_exec(&ignore_if))
      end
    end
  end
end
