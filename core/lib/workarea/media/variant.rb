# frozen_string_literal: true

require 'tempfile'

module Workarea
  module Media
    # Very small variant/processing implementation for the prototype.
    #
    # Implemented processors:
    # - :optim (jpeg encode + image_optim) for images
    class Variant
      def initialize(attachment, processor_name, *args)
        @attachment = attachment
        @processor_name = processor_name.to_sym
        @args = args
      end

      def url
        ensure_generated!
        @attachment.url(variant: @processor_name, args: @args)
      end

      def ensure_generated!
        @attachment.ensure_variant!(@processor_name, *@args)
      end
    end
  end
end
