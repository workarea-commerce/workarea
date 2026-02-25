# frozen_string_literal: true

# Mongoid expects Time fields coming back from the driver to be Time-like.
# Under some Ruby/Mongoid combinations we can end up with ISO8601 strings
# (e.g. "2026-02-25T01:23:48.719Z") which then blow up in
# Mongoid::Extensions::Time.demongoize when it calls `getlocal`.
#
# This patch is intentionally narrow: if the demongoized value is a String,
# attempt to parse it into a Time before delegating back to Mongoid.
module Workarea
  module MongoidTimeDemongoizeString
    def demongoize(object)
      if object.is_a?(String)
        require 'time'

        object = begin
          ::Time.iso8601(object)
        rescue ArgumentError
          begin
            ::Time.parse(object)
          rescue ArgumentError
            object
          end
        end
      end

      super(object)
    end
  end
end

::Time.singleton_class.prepend(Workarea::MongoidTimeDemongoizeString)
