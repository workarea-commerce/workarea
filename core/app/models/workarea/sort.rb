module Workarea
  class Sort < Struct.new(:name, :slug, :field, :direction)
    class Collection < SimpleDelegator
      def initialize(*sorts)
        super(sorts)
      end

      def find(slug)
        detect { |s| s.to_s == slug.to_s } || first
      end
    end

    def to_s
      self.slug.to_s
    end

    def to_a
      [name, slug]
    end

    def self.available
      new(I18n.t('workarea.sorts.available'),         :available,     :available,             :desc)
    end

    def self.average_order_value
      new(I18n.t('workarea.sorts.average_order_value'),  :avg_order,     :average_order_value,   :desc)
    end

    def self.destination
      new(I18n.t('workarea.sorts.destination'),       :destination,   :destination,           :asc)
    end

    def self.end
      new(I18n.t('workarea.sorts.end'),               :end,           :active_ends_at,        :desc)
    end

    def self.downloads
      new(I18n.t('workarea.sorts.downloads'),        :downloads,     :downloads,              :desc)
    end

    def self.last_updated
      new(I18n.t('workarea.sorts.last_updated'),      :last_updated,  :updated_at,            :desc)
    end

    def self.modified
      new(I18n.t('workarea.sorts.modified'),          :modified,      :updated_at,            :desc)
    end

    def self.most_orders
      new(I18n.t('workarea.sorts.most_orders'),       :most_orders,   :total_orders,          :desc)
    end

    def self.most_spent
      new(I18n.t('workarea.sorts.most_spent'),        :most_spent,    :total_spent,           :desc)
    end

    def self.name_asc
      new(I18n.t('workarea.sorts.name_asc'),          :name_asc,      :name,                  :asc)
    end

    def self.name_desc
      new(I18n.t('workarea.sorts.name_desc'),         :name_desc,     :name,                  :desc)
    end

    def self.newest
      new(I18n.t('workarea.sorts.newest'),            :newest,        :created_at,            :desc)
    end

    def self.newest_placed
      new(I18n.t('workarea.sorts.newest'),            :newest_placed, :placed_at,             :desc)
    end

    def self.oldest
      new(I18n.t('workarea.sorts.oldest'),            :oldest,        :created_at,            :asc)
    end

    def self.oldest_placed
      new(I18n.t('workarea.sorts.oldest'),            :oldest_placed, :placed_at,             :asc)
    end

    def self.path
      new(I18n.t('workarea.sorts.path'),              :path,          :path,                  :asc)
    end

    def self.pending
      new(I18n.t('workarea.sorts.pending'),           :pending,       :pending,               :desc)
    end

    def self.popularity
      new(I18n.t('workarea.sorts.popularity'),       :popularity,     :'sorts.views_score',   :desc)
    end

    def self.price_asc
      new(I18n.t('workarea.sorts.price_asc'),         :price_asc,     :'sorts.price',         :asc)
    end

    def self.price_desc
      new(I18n.t('workarea.sorts.price_desc'),        :price_desc,    :'sorts.price',         :desc)
    end

    def self.purchased
      new(I18n.t('workarea.sorts.purchased'),         :purchased,     :purchased,             :desc)
    end

    def self.query
      new(I18n.t('workarea.sorts.query'),             :query,         :query,                 :asc)
    end

    def self.rating
      new(I18n.t('workarea.sorts.rating'),            :rating,        :rating,                :desc)
    end

    def self.redemptions
      new(I18n.t('workarea.sorts.redemptions'),       :redemptions,   :total_redemptions,     :desc)
    end

    def self.relevance
      new(I18n.t('workarea.sorts.relevance'),         :relevance,      nil,                   nil)
    end

    def self.sales
      new(I18n.t('workarea.sorts.sales'),             :sales,         :sales,                 :desc)
    end

    def self.sku
      new(I18n.t('workarea.sorts.sku'),               :sku,           :id,                    :asc)
    end

    def self.start
      new(I18n.t('workarea.sorts.start'),             :start,         :active_starts_at,      :desc)
    end

    def self.title
      new(I18n.t('workarea.sorts.title'),             :title,         :title,                 :asc)
    end

    def self.top_sellers
      new(I18n.t('workarea.sorts.top_sellers'),       :top_sellers,   :'sorts.orders_score',  :desc)
    end

    def self.total
      new(I18n.t('workarea.sorts.total'),             :total,         :total_price,           :desc)
    end

    def self.type
      new(I18n.t('workarea.sorts.type'),              :type,          :type,                  :asc)
    end

    def self.published_date
      new(I18n.t('workarea.sorts.published_date'),    :published_date, :published_at,         :desc)
    end

    def self.country
      new(I18n.t('workarea.sorts.country'),           :country, :country,       :asc)
    end

    def self.postal_code
      new(I18n.t('workarea.sorts.postal_code'),       :postal_code, :postal_code,   :asc)
    end

    def self.region
      new(I18n.t('workarea.sorts.region'),            :region, :region,        :asc)
    end
  end
end
