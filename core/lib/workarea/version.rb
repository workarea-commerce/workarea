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
      MAJOR = 5
      MINOR = 0
      STRING = [MAJOR, MINOR].compact.join('.')
    end

    module ELASTICSEARCH
      MAJOR = 5
      MINOR = 6
      STRING = [MAJOR, MINOR].compact.join('.')
    end
  end
end
