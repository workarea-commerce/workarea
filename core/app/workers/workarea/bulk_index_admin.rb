module Workarea
  class BulkIndexAdmin
    include Sidekiq::Worker

    sidekiq_options lock: :until_executing

    class << self
      def perform(klass, ids)
        ids.each_slice(Workarea.config.bulk_index_batch_size) do |group|
          perform_by_models(klass.constantize.in(id: group).to_a)
        end
      end

      def perform_by_models(models)
        return if models.empty?
        Workarea::Search::Admin.bulk { documents_for(models) }
      end

      private

      def documents_for(models)
        models
          .map { |m| Workarea::Search::Admin.for(m) }
          .compact
          .select(&:should_be_indexed?)
          .map(&:as_bulk_document)
      end
    end

    def perform(klass, ids)
      self.class.perform(klass, ids)
    end
  end
end
