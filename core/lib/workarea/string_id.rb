module Workarea
  # TODO: Remove in v4
  # A class used strictly for allowing custom strings for model ids while
  # maintaining support for the use of a {BSON::ObjectId} as the default.
  # Documents within a collection using StringId for _id can be created and
  # queried with either a {String} or {BSON::ObjectId}. Legal object ids will be
  # converted before reading or writing from the database.
  #
  # @example model using StringId
  #   class Foo
  #     include Mongoid::Document
  #     field :_id, type: StringId, default: -> { BSON::ObjectId.new }
  #   end
  #
  #   Creating documents:
  #     Foo.create
  #     Foo.create('5b8ff8e84907b7367471aded')
  #     Foo.create('some_custom_id')
  #
  #   Valid queries:
  #     foo = Foo.find('5b8ff8e84907b7367471aded')
  #     foo.id #=> BSON::ObjectId('5b8ff8e84907b7367471aded')
  #
  #     foo = Foo.find(BSON::ObjectId.from_string('5b8ff8e84907b7367471aded'))
  #     foo.id #=> BSON::ObjectId('5b8ff8e84907b7367471aded')
  #
  #     foo = Foo.find('some_custom_id')
  #     foo.id #=> "some_custom_id"
  #
  class StringId < String
    class << self
      def mongoize(object)
        return if object.nil?
        object.to_s.send(:convert_to_object_id)
      end
      alias_method :demongoize, :mongoize

      def evolve(object)
        __evolve__(object) do |obj|
          obj.regexp? ? obj : obj.to_s.send(:convert_to_object_id)
        end
      end
    end
  end
end
