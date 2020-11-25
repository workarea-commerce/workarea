module Workarea
  class IndexPage
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Content::Page => [:save, :destroy] },
      lock: :until_executing
    )

    def perform(id)
      page = Content::Page.find(id)
      Search::Storefront::Page.new(page).save
    rescue Mongoid::Errors::DocumentNotFound
      Search::Storefront::Page.new(
        Content::Page.new(id: id)
      ).destroy
    end
  end
end
