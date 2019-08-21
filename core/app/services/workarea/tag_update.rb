module Workarea
  class TagUpdate
    attr_accessor :removes, :adds

    def initialize(adds: [], removes: [])
      @adds = adds
      @removes = removes
    end

    def apply(tags)
      tags.reject! { |tag| removes.include?(tag) }
      tags.concat(adds).uniq!
    end
  end
end
