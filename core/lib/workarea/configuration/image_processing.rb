module Workarea
  module Configuration
    module ImageProcessing
      extend self

      def libvips?
        !!(libvips_version =~ /\Avips-8/)
      end

      def libvips_version
        return @libvips_version if defined?(@libvips_version)
        @libvips_version = `vips -v` rescue nil
      end

      def load
        require 'dragonfly_libvips' if libvips?
      end
    end
  end
end
