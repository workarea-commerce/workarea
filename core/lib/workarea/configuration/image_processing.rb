module Workarea
  module Configuration
    module ImageProcessing
      def self.libvips?
        return @libvips if defined?(@libvips)
        @libvips = !!system('vips -v') rescue false
      end

      def self.load
        require 'dragonfly_libvips' if libvips?
      end
    end
  end
end
