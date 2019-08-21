module Workarea
  module Factories
    module Recommendation
      Factories.add(self)

      def create_recommendations(overrides = {})
        attributes = factory_defaults(:recommendations).merge(overrides)
        Workarea::Recommendation::Settings.create!(attributes)
      end

      def create_user_activity(overrides = {})
        attributes = factory_defaults(:user_activity).merge(overrides)
        Workarea::Recommendation::UserActivity.create!(attributes)
      end
    end
  end
end
