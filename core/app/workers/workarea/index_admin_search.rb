module Workarea
  class IndexAdminSearch
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      queue: 'low',
      lock: :until_executing,
      enqueue_on: {
        ApplicationDocument => [:save, :touch, :destroy],
        with: -> { IndexAdminSearch.job_arguments(self) },
        ignore_if: -> { !IndexAdminSearch.should_enqueue?(self) }
      }
    )

    def self.should_enqueue?(model)
      search_model = Search::Admin.for(model)
      search_model.present? && search_model.should_be_indexed?
    end

    def self.job_arguments(model)
      search_model = Search::Admin.for(model)
      [search_model.model.class.name, search_model.model.id]
    end

    def self.perform(model)
      search_model = Search::Admin.for(model)
      return false if search_model.blank?

      if model.persisted? && search_model.should_be_indexed?
        # For the admin, we don't want to index release changes
        Release.with_current(nil) { model.reload } if Release.current.present?

        search_model.save
      else
        search_model.try(:destroy) rescue nil # It's OK if it doesn't exist
      end
    end

    def perform(class_name, id)
      model = class_name.constantize.find_or_initialize_by(id: id)
      self.class.perform(model)
    end
  end
end
