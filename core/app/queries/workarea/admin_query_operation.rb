module Workarea
  class AdminQueryOperation
    include Enumerable

    attr_reader :options, :query_id, :ids, :exclude_ids
    delegate :params, :results, to: :query

    def initialize(options = {})
      @options = options.with_indifferent_access
      @query_id = @options[:query_id]
      @ids = Array.wrap(@options[:ids])
      @exclude_ids = Array.wrap(@options[:exclude_ids])
    end

    def query
      @query ||= GlobalID.find(query_id).tap do |query|
        query.params.merge!(options)
      end
    end

    def count
      if ids.any?
        (ids - exclude_ids).size
      else
        query.total - exclude_ids.size
      end
    end

    def use_query?
      ids.blank?
    end

    def each
      if use_query?
        create_query_to_perform_with.scroll do |results|
          results.each { |model| yield(model) unless exclude?(model) }
        end
      else
        GlobalID::Locator.locate_many(ids).each do |model|
          yield(model) unless exclude?(model)
        end
      end
    end

    private

    def create_query_to_perform_with(overrides = {})
      params = query.params.merge(overrides).merge(per_page: Workarea.config.bulk_action_per_page)
      query.class.new(params)
    end

    def exclude?(model)
      model.blank? ||
        model.to_global_id.to_param.in?(exclude_ids) ||
        model.to_global_id.in?(exclude_ids)
    end
  end
end
