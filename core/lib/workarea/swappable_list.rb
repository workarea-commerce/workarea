module Workarea
  class SwappableList
    include Enumerable

    delegate :to_s, to: :@source

    def initialize(source = [])
      @source = Array(source)
    end

    def insert(index, new_val)
      index = assert_index(index, :before)
      @source.insert(index, new_val)
    end
    alias_method :insert_before, :insert

    def insert_after(index, new_val)
      index = assert_index(index, :after)
      insert(index + 1, new_val)
    end

    def swap(target, new_val)
      index = assert_index(target, :before)
      insert(index, new_val)
      @source.delete_at(index + 1)
    end

    def delete(target)
      @source.delete(target)
    end

    def +(other)
      self.class.new(
        @source + Array(other)
      )
    end

    def -(other)
      self.class.new(
        @source - Array(other)
      )
    end

    def method_missing(method, *args, &block)
      if @source.respond_to?(method)
        @source.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super || @source.respond_to?(method_name)
    end

    def deep_dup
      self.class.new(@source.deep_dup)
    end

    private

    def assert_index(index, where)
      i = index.is_a?(Integer) ? index : @source.index(index)
      raise "No such list item to insert #{where}: #{index.inspect}" unless i
      i
    end
  end
end
