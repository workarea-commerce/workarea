module Workarea
  module Factories
    module Comment
      Factories.add(self)

      def create_comment(overrides = {})
        attributes = factory_defaults(:comment).merge(overrides)
        Workarea::Comment.create!(attributes)
      end
    end
  end
end
