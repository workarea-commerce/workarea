module Workarea
  module Navigation
    class Menu
      include ApplicationDocument
      include Releasable
      include Contentable
      include Ordering

      field :name, type: String, localize: true

      belongs_to :taxon, class_name: 'Workarea::Navigation::Taxon'

      validates :name, presence: true

      before_validation :set_name

      index({ position: 1 })

      def active?
        super && (taxon.blank? || taxon.active?)
      end

      private

      def set_name
        self.name = self.name.presence || taxon.try(:name)
      end
    end
  end
end
