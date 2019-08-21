module Workarea
  # This module exists to help track constants for reflection at runtime. This
  # is necessary because Rails' autoloading will erase values stored in class
  # or module accessors. This module must be loaded manually with `require`,
  # for the same reason.
  #
  module Constants
    mattr_accessor :cache
    self.cache ||= {}

    def self.register(type, constant)
      type = type.to_sym
      cache[type] ||= []
      cache[type] << constant unless exists?(type, constant)
    end

    def self.find(type)
      cache[type.to_sym] || []
    end

    def self.exists?(type, constant)
      (cache[type] || []).map(&:name).include?(constant.name)
    end

    def self.reset!(type)
      cache[type.to_sym] = []
    end
  end
end
