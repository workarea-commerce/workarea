# This is here to deal with bson-ruby's change to
# how it serializes ObjectId objects. Eventually,
# this can probably be removed.
#
module BSON
  class ObjectId
    def as_json(*args)
      to_s
    end
  end
end
