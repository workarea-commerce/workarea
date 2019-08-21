module Workarea
  class User
    module Avatar
      extend ActiveSupport::Concern

      included do
        extend Dragonfly::Model

        field :avatar_name, type: String
        field :avatar_uid, type: String

        dragonfly_accessor :avatar, app: :workarea
      end

      def avatar_image_url
        if avatar.present?
          avatar.process(:avatar).url
        elsif !Rails.env.test?
          gravatar_url
        else
          'workarea/core/placeholder.png'
        end
      end

      def gravatar_url(options = {})
        options = Workarea.config.gravatar_options.merge(options)
        hash = Digest::MD5.hexdigest(email.downcase)
        "https://www.gravatar.com/avatar/#{hash}?#{options.to_query}"
      end
    end
  end
end
