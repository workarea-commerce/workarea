module ActiveSupport
  class Duration
    class << self
      def mongoize(object)
        object.parts.to_a.first.reverse
      end
      alias_method :evolve, :mongoize

      def demongoize(object)
        object.first.to_i.send(object.last.to_sym)
      end
    end
  end
end
