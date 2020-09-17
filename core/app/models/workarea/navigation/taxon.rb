module Workarea
  module Navigation
    class Taxon
      include ApplicationDocument
      include Mongoid::Tree
      include Mongoid::Tree::Ordering
      include Mongoid::Tree::Traversal

      field :name, type: String, localize: true
      field :navigable_slug, type: String
      field :url, type: String
      field :children_count, type: Integer, default: 0

      index({ navigable_slug: 1 })
      index({ navigable_id: 1 })
      index({ url: 1 })

      # redefine to add the counter cache
      belongs_to :parent,
        class_name: self.name,
        inverse_of: :children,
        index: true,
        validate: false,
        counter_cache: :children_count,
        optional: true # a root will not have a parent

      belongs_to :navigable,
        inverse_of: :taxon,
        polymorphic: true,
        touch: true,
        index: true,
        optional: true

      scope :highest, -> { order_by(:depth.asc) }

      validates :name, presence: true
      validates :navigable, uniqueness: { allow_blank: true }

      before_validation :set_parent
      before_validation { |l| TaxonCache.set(l) }
      after_rearrange :update_children_count
      before_destroy :validate_not_in_menu
      before_destroy :destroy_children

      def self.root
        super || begin
          taxon = new(
            name: I18n.t('workarea.storefront.layouts.home'),
            url: Storefront::Engine.routes.url_helpers.root_path
          )

          taxon.instance_variable_set(:@allow_root, true)
          taxon.tap(&:save!)
        end
      end

      # Whether this taxon has any children. Uses the counter cache
      # defined in #children_count. This method exists only as a
      # performance improvement over the `taxon.children.any?`.
      #
      # @return [Boolean]
      #
      def has_children?
        children_count > 0
      end

      def move_to_position(new_position)
        new_position = new_position.to_i

        if new_position == 0
          move_to_top
        elsif sibling = siblings.find_by(position: new_position) rescue nil
          move_above(sibling)
        else
          move_to_bottom
        end
      end

      def url?
        url.present?
      end

      def placeholder?
        !navigable? && !url?
      end

      def navigable?
        navigable_id.present?
      end

      def resource_name
        ActiveSupport::StringInquirer.new(
          if placeholder?
            'placeholder'
          elsif url?
            'url'
          else
            navigable_type.constantize.model_name.element
          end
        )
      end

      def menu
        Menu.where(taxon_id: id).first
      end

      def in_menu?
        menu.present?
      end

      # Whether this taxon should be shown in the storefront, dependent on
      # it's navigable being active.
      #
      # @return [Boolean]
      #
      def active?
        !navigable? || !navigable.respond_to?(:active?) || navigable.active?
      end

      def touch
        navigable.touch if navigable.present?
        super
      end

      def search_results?
        navigable.is_a?(SearchResults)
      end

      def show_in_sitemap?
        !placeholder? && active? && (navigable.present? || url.to_s.start_with?('http', '/'))
      end

      private

      def set_parent
        if parent.blank? && !@allow_root
          self.parent = self.class.root
          rearrange
        end
      end

      def update_children_count
        self.children_count = children.count
      end

      def validate_not_in_menu
        if in_menu?
          errors.add(:base, "You cannot delete taxonomy that's in primary navigation")
          throw :abort
        end
      end
    end
  end
end
