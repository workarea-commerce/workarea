module Workarea
  class Categorization
    include Enumerable
    delegate :blank?, :present?, :size, :length, :to_a, to: :all

    def initialize(product = nil)
      @product = product
    end

    def each(&block)
      all.each(&block)
    end

    def default_model
      key = [@product.cache_key, 'default_category', Release.current&.id].compact.join('/')

      @default_model ||= Rails.cache.fetch(key, expires_in: Workarea.config.cache_expirations.products_default_category) do
        manual_default_model ||
          to_models.sort_by(&:created_at).select(&:active?).first
      end
    end

    def default
      default_model.try(:id)
    end

    def manual
      manual_models.map(&:id)
    end

    def queries
      return [] if @product.blank?
      @queries ||= Search::Storefront::CategoryQuery.find_by_product(@product)
    end

    def to_models
      @to_models ||= (manual_models + query_models).uniq
    end

    def manual_default_model
      return unless @product.default_category_id.present?

      @manual_default_model ||=
        Catalog::Category.where(id: @product.default_category_id)
                         .detect { |c| c.active? && c.id.to_s.in?(all)  }
    end

    private

    def all
      (manual + queries).map(&:to_s).uniq
    end

    def query_models
      @query_models ||= Catalog::Category.any_in(id: queries).to_a
    end

    def manual_models
      return [] if @product.blank?
      @manual_models ||= FeaturedCategorization.new(@product.id).to_a
    end
  end
end
