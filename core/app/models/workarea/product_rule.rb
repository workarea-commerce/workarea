module Workarea
  class ProductRule
    include ApplicationDocument
    include Releasable

    OPERATORS = %w(
      greater_than
      greater_than_or_equal
      equals
      not_equal
      less_than
      less_than_or_equal
    )

    field :name, type: String, localize: true
    field :operator, type: String
    field :value, type: String, localize: true

    embedded_in :product_list, polymorphic: true, inverse_of: :product_rules

    validate :value_is_date_if_field_is_date
    validates :value, presence: true
    validates :name, presence: true
    validates :operator, presence: true

    def self.usable
      scoped.select(&:active?).select(&:valid?)
    end

    # The identifier for which admin partials to render for this rule.
    #
    # @return [Symbol]
    #
    def slug
      name.systemize.to_sym if name.present?
    end

    # The field in Elasticsearch this rule checks against
    #
    # @return [String]
    #
    def field
      return if name.blank?
      Workarea.config.product_rule_fields[slug] || "facets.#{name.systemize}"
    end

    alias_method :value_field, :value

    # Returns the value that the rule uses to compare.
    #
    # @return [Comparable]
    #
    def value
      return Time.zone.parse(value_field) rescue value_field if created_at?
      value_field
    end

    # This is HACK for the fact that we want a CSV string in value, but our
    # current solution for submitting category IDs submits an array. :(
    def value=(val)
      if val.is_a?(Array)
        super(val.join(','))
      else
        super(val)
      end
    end

    def sale?
      slug == :on_sale
    end

    def search?
      slug == :search
    end

    def inventory?
      slug == :inventory
    end

    def created_at?
      slug == :created_at
    end

    def equality?
      operator == 'equals'
    end

    def inequality?
      operator == 'not_equal'
    end

    def true?
      value.downcase == 'true'
    end

    def false?
      value.downcase == 'false'
    end

    def comparison?
      operator.in?([
        'greater_than',
        'greater_than_or_equal',
        'less_than',
        'less_than_or_equal'
      ])
    end

    # Determines if the rule is a for a category.
    #
    # @return [Boolean]
    #
    def category?
      slug == :category
    end

    def product_exclusion?
      slug == :excluded_products
    end

    # Used in query-building for Elasticsearch
    #
    # @return [Array<String>]
    #
    def terms
      value.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    private

    def value_is_date_if_field_is_date
      if created_at?
        begin
          Time.zone.parse(value_field)
        rescue
          errors.add(
            :base,
            I18n.t('workarea.errors.messages.not_a_date')
          )
        end
      end
    end
  end
end
