module Mongoid
  module Document
    #
    # Returns all the embedded children in this document by recursion.
    #
    # *WARNING!*
    # If you have recursively defined relations, this method will cause a stack
    # overflow.
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
