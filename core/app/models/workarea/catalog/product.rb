module Workarea
  module Catalog
    class Product
      include ApplicationDocument
      include Mongoid::Document::Taggable
      include Releasable
      include Navigable
      include Commentable
      include Details

      field :_id, type: String, default: -> { SecureRandom.hex(5).upcase }
      field :name, type: String, localize: true
      field :filters, type: Hash, default: {}, localize: true
      field :template, type: String, default: 'generic'
      field :customizations, type: String
      field :browser_title, type: String, localize: true
      field :meta_description, type: String, localize: true
      field :description, type: String, localize: true
      field :last_indexed_at, type: Time
      field :purchasable, type: Boolean, default: true
      field :default_category_id, type: String

      # DEPRECATED. This field will be remove in v3.6 in favor of using
      # Fulfillment::SKU to determine behavior in checkout for items not
      # requiring phsyical fulfillment.
      #
      # TODO: remove in v3.6
      #
      field :digital, type: Boolean, default: false

      index({ 'variants.sku': 1 })
      index({ last_indexed_at: 1 })
      index(purchasable: 1)
      index(created_at: 1)
      if Workarea.config.localized_image_options
        I18n.for_each_locale { index("images.option.#{I18n.locale}" => 1) }
      else
        index({ 'images.option': 1 })
      end

      embeds_many :variants, class_name: 'Workarea::Catalog::Variant'
      embeds_many :images, class_name: 'Workarea::Catalog::ProductImage'

      belongs_to :copied_from,
        class_name: 'Workarea::Catalog::Product',
        optional: true

      validate :no_type_filter
      validates :name, presence: true

      scope :recent, ->(l = 5) { order_by([:created_at, :desc]).limit(l) }
      scope :purchasable, -> { where(purchasable: true) }

      before_validation :ensure_template

      def self.sorts
        [Sort.newest, Sort.modified, Sort.sales, Sort.name_asc, Sort.name_desc]
      end

      # Finds the first product that has the given SKU. Tries to match exactly,
      # but will look for a case-insensitive match if exact match isn't found.
      #
      # @param sku [String]
      # @return [Catalog::Product, nil]
      #
      def self.find_by_sku(sku)
        return unless sku.present?

        begin
          find_by('variants.sku' => sku)
        rescue Mongoid::Errors::DocumentNotFound
          regex = /^#{::Regexp.quote(sku)}$/i
          find_by('variants.sku' => regex) rescue nil
        end
      end

      # Find any and all products which have a variant set with the SKU, for
      # the purposes of updating search indexes, caches, etc.
      #
      # @param sku [String]
      # @return [Array<Catalog::Product>]
      #
      def self.find_for_update_by_sku(sku)
        where('variants.sku' => sku)
      end

      # Finds all products that were updated:
      # * after options[:start], if supplied
      # * before options[:end], if supplied
      #
      # If neither are supplied, then all products are returned.
      #
      # @param options [Hash]
      # @return [Mongoid::Criteria]
      #
      def self.find_by_update(options)
        context = all
        context = context.where(:updated_at.gte => options[:start]) if options[:start].present?
        context = context.where(:updated_at.lte => options[:end])   if options[:end].present?
        context
      end

      # Finds the corresponding products for the given ids that are active
      # and returns them in the same order.
      #
      # @return [Array<String>] representing Catalog::Product#id
      # @return [Array] of Catalog::Product
      #
      def self.find_ordered_for_display(*ids)
        find_ordered(ids).select(&:active?)
      end

      def self.autocomplete_image_options(string)
        regex = /#{::Regexp.quote(string)}/i
        key = 'images.option'
        key += ".#{I18n.locale}" if Workarea.config.localized_image_options

        where(key => regex).map do |product|
          product.images.where(option: regex).map(&:option)
        end.flatten.map(&:titleize).uniq
      end

      def categories
        Category.any_in(product_ids: id)
      end

      def category_ids
        categories.map(&:id)
      end

      def skus
        variants.map(&:sku).uniq
      end

      def active?
        super && active_by_relations?
      end

      # This hook allows plugins extending this model a place to hook into
      # #active? without overriding all the logic in that method's `super`. For
      # example, package products.
      #
      # @return [Boolean]
      #
      def active_by_relations?
        variants.active.any?
      end

      # Whether to allow purchasing on this product. This is always false if
      # there are no variants associated with the product because of all the
      # detail page and cart logic depending on the existence of SKUs and
      # variants.
      #
      # @return [Boolean]
      #
      def purchasable?
        variants.active.blank? ? false : super
      end

      private

      def no_type_filter
        self.filters.keys.each do |key|
          if key =~ /^type$/i
            errors.add(
              :filters,
              I18n.t('workarea.errors.messages.contains_type')
            )
          end
        end
      end

      def ensure_template
        self.template = 'generic' if template.blank?
      end
    end
  end
end
