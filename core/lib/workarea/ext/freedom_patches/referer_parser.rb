module RefererParser
  class Parser
    def sources
      @name_hash.values.map { |v| v[:source] }
    end
  end
end
