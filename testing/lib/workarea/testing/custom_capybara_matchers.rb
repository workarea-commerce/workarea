module Capybara
  module Node
    class Base
      def has_ordered_text?(*args)
        assert_text(:visible, /#{args.join('.*')}/m)
      rescue Capybara::ExpectationNotMet
        raise Capybara::ExpectationNotMet, "Did not find text in the order #{args.join(', ')}"
      end
    end
  end

  class Session
    def has_ordered_text?(*args)
      @touched = true # doing this because in the Capybara source matchers do this
      current_scope.has_ordered_text?(*args)
    end
  end
end
