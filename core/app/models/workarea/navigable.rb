module Workarea
  module Navigable
    extend ActiveSupport::Concern

    included do
      field :slug, type: String

      index({ slug: 1 }, { unique: true })

      validates :slug, presence: true, uniqueness: true

      has_one :taxon,
        inverse_of: :navigable,
        class_name: 'Workarea::Navigation::Taxon',
        dependent: :destroy

      before_validation :generate_slug, if: proc { |l| l.slug.blank? }
      after_validation :reset_slug!, if: proc { |l| l.errors.present? }
      after_save :update_taxon_slug
    end

    def to_param
      slug
    end

    def slug=(val)
      if val.nil?
        super(val)
      else
        super(val.to_s.parameterize)
      end
    end

    private

    def generate_slug
      return nil unless name.present?
      self.slug = FindUniqueSlug.new(self, name.delete("'").parameterize).slug
    end

    def update_taxon_slug
      return if taxon.blank? || changes['slug'].blank?
      taxon.set(navigable_slug: slug)
    end
  end
end
