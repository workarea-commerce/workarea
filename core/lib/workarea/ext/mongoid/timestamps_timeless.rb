# see https://github.com/mongoid/mongoid/pull/4110
# This can be removed after the above PR is accepted and the version in the Gemfile is bumped to one the includes the PR. The test that was committed along with this will verify that the Gem upgrade fixes the issue.

module Mongoid
  module Timestamps

    module Created
      def set_created_at
        if !timeless? && !created_at
          time = Time.current.utc
          self.updated_at = time if is_a?(Updated) && !updated_at_changed?
          self.created_at = time
        end

        clear_timeless_option
      end
    end

    module Updated
      def set_updated_at
        if able_to_set_updated_at?
          self.updated_at = Time.current.utc unless updated_at_changed?
        end

        clear_timeless_option
      end
    end

    module Timeless
      def clear_timeless_option
        if self.persisted?
          self.class.clear_timeless_option_on_update
        else
          self.class.clear_timeless_option
        end
        true
      end

      module ClassMethods

        def clear_timeless_option_on_update
          if counter = Timeless[name]
            counter -= 1 if self < Mongoid::Timestamps::Created
            counter -= 1 if self < Mongoid::Timestamps::Updated
            Timeless[name] = (counter == 0) ? nil : counter
          end
        end
      end
    end
  end
end
