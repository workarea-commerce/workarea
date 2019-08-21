module Workarea
  # Redis lock primative suitable for single instance redis configurations.
  # Allows the prevention of multiple processes from performing actions guarded
  # by the lock. Our primary use case is preventing multiple processes from
  # modifying an order simultaneously during checkout.
  #
  class Lock
    class Locked < StandardError; end

    class << self
      # find an existing lock.
      #
      # @param [String] key The key of the lock you want to find
      #
      # @return [String, NilClass]
      #   the value stored within the lock or nil if the key does not exist
      #
      def find(key)
        Workarea.redis.get(key).presence
      end

      # check if a lock exists
      #
      # @param [String] key The key of the lock you want to check
      #
      # @return [Boolean]
      #
      def exists?(key)
        find(key).present?
      end

      # Set a new lock. By default, it will only succeed if the lock does
      # not already exist and will unlock passed on the configurable time
      # defined as {Workarea.config.default_lock_expiration}.
      #
      # @param [String] key The key of the lock to be created
      # @param [String] value The value to set on the lock
      # @param [Hash] options
      # @option options [Number] :ex Set the specified expire time, in seconds
      # @option options [Boolean] :nx Only set lock if it does not exist
      #
      # @raise [Workarea::Lock::Locked]
      #   raised if a lock with the same key already exists and `nx: true`
      #
      # @return [String, Boolean] `"OK"` or true, false if `nx: true`
      #
      def create!(key, value, options = {})
        default = {
          ex: Workarea.config.default_lock_expiration,
          nx: true # blocks creation of existing lock
        }

        result = Workarea.redis.set(key, value, default.merge(options))
        raise Locked, "#{key} is already locked" unless result
        result
      end

      # Remove a lock. Will only remove a lock matching the key if the value
      # also matches. This prevents accidently removing a lock set by another
      # process.
      #
      # @param [String] key The key of the lock you want to destroy
      # @param [String] value The expected value of the lock
      #
      # @return [Boolean]
      #
      def destroy!(key, value)
        stored_value = find(key)
        return true if stored_value.nil? || stored_value != value

        Workarea.redis.del(key) >= 1
      end
    end
  end
end
