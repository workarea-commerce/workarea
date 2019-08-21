module Workarea
  class RedirectNavigableSlugs
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker
    include I18n::DefaultUrlOptions

    sidekiq_options(
      enqueue_on: {
        Navigable => :update,
        with: -> { [self.class.name, id, changes] },
        ignore_if: -> { changes['slug'].blank? }
      },
      queue: 'low'
    )

    # Do not enable by default. We do not want this to run in bulk tasks
    # such as importing or bulk actions. However, this is enabled for all admin
    # activity from the {Workarea::Admin::ApplicationController} and can be
    # enabled on demand through the {Sidekiq::Callbacks} interface.
    def self.enabled?
      !!enabled
    end

    def perform(class_name, id, changes)
      old_slug, _new_slug = changes['slug']

      model = class_name.constantize.find_or_initialize_by(id: id)
      return unless model.persisted?

      I18n.for_each_locale do
        old_path = navigable_path(model, old_slug)
        next if Navigation::Redirect.find_by_path(old_path).present?

        Navigation::Redirect.create(
          path: old_path,
          destination: navigable_path(model)
        )
      end
    end

    def navigable_path(model, url_params = nil)
      params = default_url_options.merge(id: url_params || model)
      resource_name = model.class.model_name.element
      storefront_routes.send("#{resource_name}_path", params)
    end

    def storefront_routes
      Storefront::Engine.routes.url_helpers
    end
  end
end
