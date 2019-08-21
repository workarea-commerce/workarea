module Workarea
  class BulkActionSelections
    attr_reader :bulk_action, :params

    def initialize(id, params = {})
      @bulk_action = BulkAction.find(id)
      @params = params
    end

    def results
      @results ||=
        if bulk_action.ids.any?
          models = find_from_global_ids(bulk_action.ids)
          PagedArray.from(models, 1, models.size, models.size)
        else
          bulk_action.admin_query.class.new(query_params).results
        end
    end

    private

    def query_params
      bulk_action
        .params
        .merge(params)
        .merge(exclude_ids: excluded_search_ids)
    end

    def excluded_search_ids
      find_from_global_ids(bulk_action.exclude_ids).map do |model|
        Search::Admin.for(model).id
      end
    end

    def find_from_global_ids(ids)
      GlobalID::Locator.locate_many(ids)
    end
  end
end
