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

  module Time
    def to_bson(buffer = ByteBuffer.new, validating_keys = Config.validating_keys?)
      buffer.put_int64((to_i * 1000) + (usec / 1000))
    end
  end
end
