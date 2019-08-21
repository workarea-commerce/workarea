module Workarea
  module Pricing
    class Discount
      module Conditions
        module UserTags
          extend ActiveSupport::Concern

          included do
            # @!attribute user_tags
            #   @return [Array] an array of strings of eligible tags on a user.
            #
            field :user_tags, type: Array, default: []
            list_field :user_tags

            add_qualifier :user_tags_qualify?
            index({ user_tags: 1 })
          end

          def user_tag?
            user_tags.present?
          end

          def user_tags_qualify?(order)
            return true unless user_tag?
            return false unless order.user_id.present?

            user = Workarea::User.find(order.user_id) rescue nil
            return false unless user.present?

            (user.tags & user_tags).present?
          end
        end
      end
    end
  end
end
