# frozen_string_literal: true

# Mongoid 9+ requires "mongoid/fields/encrypted" during boot.
#
# Workarea depends on the `mongoid-encrypted` gem for Mongoid 7.x, and that gem
# also provides a file at this path. Under Mongoid 9+, the `mongoid-encrypted`
# implementation calls APIs that no longer exist at the time the file is
# required (see: Mongoid::Fields.option), which prevents Rails from booting.
#
# By providing a compatible implementation here (earlier on the load path than
# bundled gems), we allow Mongoid 9+ to boot while preserving existing behavior
# for older Mongoid versions.

module Mongoid
  module Fields
    # Represents a field that should be encrypted.
    #
    # This mirrors the Mongoid 9 implementation; it is intentionally small and
    # avoids referencing Mongoid internals that may not be initialized yet.
    class Encrypted < Standard
      def initialize(name, options = {})
        @encryption_options = if options[:encrypt].is_a?(Hash)
                                options[:encrypt]
                              else
                                {}
                              end
        super
      end

      def deterministic?
        @encryption_options[:deterministic]
      end

      def key_id
        @encryption_options[:key_id]
      end

      def key_name_field
        @encryption_options[:key_name_field]
      end

      # @api private
      def set_key_id(key_id)
        @encryption_options[:key_id] = key_id
      end
    end
  end
end
