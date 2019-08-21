module Workarea
  class IndexHelp
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Help::Article => [:save, :destroy] }
    )

    def perform(id)
      if article = Help::Article.find(id) rescue nil
        Search::Help.new(article).save
      else
        Search::Help.delete(id)
      end
    end
  end
end
