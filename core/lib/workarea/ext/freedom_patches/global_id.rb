class GlobalID
  class << self
    def demongoize(object)
      GlobalID.new(object)
    end

    def mongoize(object)
      case object
      when GlobalID then object.mongoize
      when String then GlobalID.new(object).mongoize
      else object
      end
    end

    def evolve(object)
      case object
      when GlobalID then object.mongoize
      else object
      end
    end
  end

  alias_method :mongoize, :to_s
end
