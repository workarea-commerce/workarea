module Workarea
  class SetNavigable
    class MissingSlugMapEntry < RuntimeError; end

    cattr_accessor :slug_map
    self.slug_map ||= {
      'page' => Content::Page,
      'category' => Catalog::Category,
      'product' => Catalog::Product
    }

    def initialize(taxon, params)
      @taxon = taxon
      @params = params
    end

    def new_navigable?
      @params[:new_navigable_type].present? &&
        @params[:new_navigable_name].present?
    end

    def existing_navigable?
      @params[:navigable_type].present? && @params[:navigable_id].present?
    end

    def navigable?
      new_navigable? || existing_navigable?
    end

    def slug
      if new_navigable?
        @params[:new_navigable_type]
      elsif existing_navigable?
        @params[:navigable_type]
      end
    end

    def navigable_class
      slug_map[slug] if slug.present?
    end

    def navigable
      assert_navigable_class if navigable?

      if new_navigable?
        navigable_class.create!(name: @params[:new_navigable_name])
      elsif existing_navigable?
        navigable_class.find(@params[:navigable_id])
      end
    end

    def set
      @taxon.navigable = navigable
    end

    private

    def assert_navigable_class
      if navigable_class.nil?
        raise(
          MissingSlugMapEntry,
          <<-message
            There is no entry in the slug map for '#{slug}'.
            You must add a map from slug to class in Workarea::SetNavigable:
            Workarea::SetNavigable.slug_map['#{slug}'] = #{slug.to_s.classify}
          message
        )
      end
    end
  end
end
