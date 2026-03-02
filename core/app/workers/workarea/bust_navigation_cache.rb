# frozen_string_literal: true
module Workarea
  class BustNavigationCache
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Navigation::Taxon => :save },
      queue: 'low',
      retry: false
    )

    def perform(id)
      taxon = Navigation::Taxon.find(id)
      taxon.ancestors.each(&:touch)
      taxon.descendants.each(&:touch)
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end
end
