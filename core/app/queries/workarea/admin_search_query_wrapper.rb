# Query class for models to match the API of {Search::Query}.
# Used in exporting models that aren't put into Elasticsearch.
#
module Workarea
  class AdminSearchQueryWrapper
    include Search::Pagination
    include GlobalID::Identification

    attr_reader :params

    def self.find(id)
      new(JSON.parse(id))
    end

    def initialize(params = {})
      @params = params.with_indifferent_access
      @params[:model_type] = @params[:model_type].to_s # ensures ID serialization works for it
    end

    def id
      params.to_json
    end

    def klass
      params[:model_type].constantize
    end

    def results
      criteria = klass_criteria
      criteria = criteria.where(filters) if filters.present?
      criteria.order_by(sort).page(page).per(per_page)
    end

    def scroll(options = {}, &block) # to match Search::Query method arguments
      # Without this call to clear cache, the mongo driver raises:
      #  NotImplementedError: Cannot restart iteration of a cursor which issued a getMore
      #
      # I think this is a bug in how the QueryCache works.
      Mongoid::QueryCache.clear_cache

      criteria = results
      criteria.total_pages.times do |page|
        yield criteria.page(page + 1).per(per_page).to_a
      end
    end

    def klass_criteria
      return klass.all unless params[:q].present? && klass.respond_to?(:search)
      klass.search(params[:q])
    end

    def filters
      params[:query_params]
    end

    def total
      results.count
    end

    def sort
      if klass.respond_to?(:sorts)
        result = params[:sort].presence || klass.sorts.first.to_s

        klass.sorts.map do |sortable|
          if sortable.to_s == result.to_s
            return [sortable.field, sortable.direction]
          end
        end
      end

      [:created_at, :desc]
    end
  end
end
