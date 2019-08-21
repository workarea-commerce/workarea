module Workarea
  class FindUniqueSlug
    def initialize(navigable, original_slug)
      @navigable = navigable
      @original_slug = original_slug
    end

    def slug
      if existing_slugs.count > 0
        existing_slugs.sort! do |a, b|
          (pattern.match(a)[1] || -1).to_i <=> (pattern.match(b)[1] || -1).to_i
        end

        max_counter = existing_slugs.last.match(/-(\d+)$/).try(:[], 1).to_i
        @original_slug + "-#{max_counter + 1}"
      else
        @original_slug
      end
    end

    def existing_slugs
      @existing_slugs ||=
        @navigable
          .class
          .all
          .except(@navigable.id)
          .where(slug: pattern)
          .pluck(:slug)
    end

    def pattern
      @pattern ||= /^#{::Regexp.escape(@original_slug)}(?:-(\d+))?$/
    end
  end
end
