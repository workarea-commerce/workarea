module Mongoid
  class Criteria
    def each_by(by, &block)
      i = 0
      total = 0
      set_limit = options[:limit]

      while (results = ordered_clone.skip(i).limit(by)) && results.exists?
        results.each do |result|
          return self if set_limit && set_limit >= total && total > 0

          total += 1
          yield result
        end

        i += by
      end

      self
    end

    def each_slice_of(size, &block)
      total = 0
      set_limit = options[:limit]

      while (results = ordered_clone.skip(total).limit(size)) && results.exists?
        total += size

        if set_limit && total > set_limit
          yield results.first(total - set_limit)
          return self
        else
          yield results
        end
      end

      self
    end

    private

    def ordered_clone
      options[:sort] ? clone : clone.asc(:_id)
    end
  end
end
