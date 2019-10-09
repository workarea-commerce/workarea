module Workarea
  module FeaturedProducts
    extend ActiveSupport::Concern

    included do
      field :product_ids, type: Array, default: []
      before_validation :clean_product_ids

      scope :by_product, ->(id) { self.in(product_ids: id) }
      index({ product_ids: 1 })
    end

    def self.changesets(*product_ids)
      Release::Changeset.any_of(
        { 'changeset.product_ids' => { '$in' => product_ids } },
        { 'original.product_ids' => { '$in' => product_ids } }
      )
    end

    def featured_products?
      product_ids.present?
    end

    def featured_product?(id)
      id.to_s.in?(product_ids)
    end

    def add_product(id)
      product_ids.prepend(id)
      save
    end

    def remove_product(id_to_remove)
      product_ids.reject! { |id| id == id_to_remove }
      save
    end

    private

    def clean_product_ids
      if product_ids.present?
        product_ids.reject!(&:blank?)
        product_ids.uniq!
      end
    end
  end
end
