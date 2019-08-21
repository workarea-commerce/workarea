module Workarea
  class BulkAction
    include ApplicationDocument

    field :query_id, type: String
    field :ids, type: Array, default: []
    field :exclude_ids, type: Array, default: []
    field :completed_at, type: Time

    before_validation :clean_blank_ids

    validate :something_to_act_on

    before_save :convert_query_to_ids

    delegate :params, :count, to: :admin_query

    index({ _type: 1 })
    index(
      { created_at: 1 },
      { expire_after_seconds: Workarea.config.bulk_action_expiration.to_i }
    )

    def perform!
      admin_query.each { |m| act_on!(m) }
    end

    def act_on!(model)
      raise NotImplementedError
    end

    def completed!
      update_attribute(:completed_at, Time.current)
    end

    def completed?
      !!completed_at
    end

    def reset_to_default!
      attributes
        .except(*BulkAction.fields.keys)
        .each { |a, _| send("reset_#{a}_to_default!") }

      self
    end

    # For reasonably sized queries, we want to store the ids of the results
    # to maintain the original result set acted on in the case that an
    # edit removes a result from the query during the bulk action.
    def convert_query_to_ids
      return if ids.present? || admin_query.results.total_pages > 10

      self.ids =
        Array.new(admin_query.results.total_pages) do |page|
          page_params = admin_query.params.merge(page: page + 1)
          page_search = admin_query.query.class.new(page_params)

          page_search.results.map do |model|
            id = model.to_global_id.to_param
            id unless id.in?(exclude_ids)
          end
        end.flatten.compact
    end

    def admin_query
      @admin_query ||= AdminQueryOperation.new(attributes)
    end

    private

    def something_to_act_on
      if query_id.blank? && ids.blank?
        errors.add(:base, I18n.t('workarea.errors.messages.nothing_to_act_on'))
      end
    end

    def clean_blank_ids
      ids.reject!(&:blank?)
    end
  end
end
