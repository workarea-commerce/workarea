# Patch BSON::Document to handle deep_symbolize_keys! deprecation
# BSON 5.x deprecates calling deep_symbolize_keys! directly on BSON::Document
# and will raise an error in v6. This patch automatically converts to Hash first.

if defined?(BSON::Document)
  class BSON::Document
    # Save the original method if it exists
    if method_defined?(:deep_symbolize_keys!)
      alias_method :original_bson_deep_symbolize_keys!, :deep_symbolize_keys!
      
      # Override to convert to Hash first, then symbolize
      def deep_symbolize_keys!
        # Convert to regular Hash to avoid BSON deprecation
        hash = to_h
        # Call deep_symbolize_keys! on the Hash
        hash.deep_symbolize_keys!
        # Replace our contents with the symbolized hash
        replace(hash)
        self
      end
    end
  end
end
