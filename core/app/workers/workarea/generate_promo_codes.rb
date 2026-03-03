# frozen_string_literal: true

module Workarea
  class GeneratePromoCodes
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Pricing::Discount::CodeList => :create }

    def perform(id)
      Pricing::Discount::CodeList.find(id).generate_promo_codes!
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end
end
