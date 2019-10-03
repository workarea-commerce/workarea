module Workarea
  class Segment
    module Rules
      class LoggedIn < Base
        field :logged_in, type: Boolean, default: false

        def qualifies?(visit)
          logged_in? == visit.logged_in?
        end
      end
    end
  end
end
