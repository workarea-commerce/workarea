module Workarea
  module Catalog
    class Category
      include ApplicationDocument
      include Mongoid::Document::Taggable
      include Releasable
      include Navigable
      include Contentable
      include Commentable
      include FeaturedProducts
      include ProductList

      field :_id, type: StringId, default: -> { BSON::ObjectId.new }
      field :name, type: String, localize: true
      field :client_id, type: String
      field :show_navigation, type: Boolean, default: true
      field :default_sort, type: String, default: 'top_sellers'
      field :terms_facets, type: Array, default: []
      field :range_facets, type: Hash, default: {}
      list_field :terms_facets

      validates :name, presence: true
      validates :client_id, uniqueness: true, allow_blank: true

      scope :recent, ->(l = 5) { order_by([:created_at, :desc]).limit(l) }
      index({ client_id: 1 })
    end
  end
end
