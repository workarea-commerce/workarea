module Mongoid
  module Document
    # Returns all the embedded children in this document by recursion.
    #
    # @return [Array<Mongoid::Document>]
    #
    def embedded_children
      result = []

      embedded_relations.each do |name, metadata|
        Array.wrap(send(name)).each do |child|
          result << child
          result += child.embedded_children
        end
      end

      result
    end
  end
end
