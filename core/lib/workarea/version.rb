module Workarea
  module VERSION
    STRING = '3.4.26'.freeze

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
