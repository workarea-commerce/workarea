module Workarea
  module Lockable
    # The key used to obtain a lock for this object. Requires the object
    # responds to #id. Remains consistent across instances of the same object.
    #
    # @return [String]
    #
    def lock_key
      "#{self.class.name.underscore}/#{id}/lock"
    end

    # The value set on the lock unless otherwise specified. Derived
    # from the lock_key, the object id of the instance of the Lockable object,
    # and the microseconds since the epoch. A unique key on each instance
    # ensures the instance can unlock itself but cannot be unlocked by any
    # other instance.
    #
    # @return [String]
    #
    def default_lock_value
      @default_lock_value ||=
        "#{lock_key}/#{object_id}/#{DateTime.current.strftime("%Q")}"
    end

    # Check if there is a lock for this object.
    #
    # @return [Boolean]
    #
    def locked?
      Lock.exists?(lock_key)
    end

    # Obtain a lock.
    #
    # @see Workarea::Lock#create! for more accepted options.
    #
    # @param [Hash] options options to pass to lock
    # @option options [String] :value The value to set on the lock
    #
    # @return [Boolean]
    #
    def lock!(options = {})
      value = options.delete(:value) || default_lock_value
      Lock.create!(lock_key, value, options)
    end

    # Release the lock. Must match key and value to be released.
    #
    # @return [Boolean]
    #   true is returned whether or not a matching lock is found. false will
    #   only be returned if the deletion of a matched lock fails.
    #
    def unlock!(value: nil)
      value ||= default_lock_value
      Lock.destroy!(lock_key, value)
    end
  end
end
