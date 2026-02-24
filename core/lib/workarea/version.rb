module Workarea
  module VERSION
    MAJOR = 3
    MINOR = 6
    PATCH = 0
    PRE   = 'pre'
    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')

    module MONGODB
      MAJOR = 4
      MINOR = 0
      STRING = [MAJOR, MINOR].compact.join('.')
    end

    module REDIS
      MAJOR = 6
      MINOR = 2
      STRING = [MAJOR, MINOR].compact.join('.')
    end

    module ELASTICSEARCH
      # Workarea's Elasticsearch client code uses the `_doc` type and typed
      # endpoints, which require Elasticsearch 6.x+. Using 5.x causes CI failures
      # like: invalid_type_name_exception (mapping type name [_doc] can't start with '_').
      MAJOR = 6
      MINOR = 8
      STRING = [MAJOR, MINOR].compact.join('.')
    end
  end
end
