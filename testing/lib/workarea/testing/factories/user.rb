module Workarea
  module Factories
    module User
      Factories.add(self)

      def create_user(overrides = {})
        attributes = factory_defaults(:user).merge(overrides)

        Workarea::User.new(attributes).tap do |user|
          user.save!
          Factories.user_count += 1
        end
      end

      def user_avatar_file_path
        Factories::User.user_avatar_file_path
      end

      def self.user_avatar_file_path
        Testing::Engine.root.join('lib', 'workarea', 'testing', 'user_avatar.jpg')
      end
    end
  end
end
