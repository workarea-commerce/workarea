module Workarea
  module Commentable
    extend ActiveSupport::Concern

    included do
      field :subscribed_user_ids, type: Array, default: []
      has_many :comments,
        class_name: 'Workarea::Comment',
        as: :commentable

      before_save do
        subscribed_user_ids.map!(&:to_s).map!(&:downcase) if subscribed_user_ids.present?
      end
    end

    def add_subscription(list)
      all = subscribed_user_ids + clean_subscription_list(list)
      update_attribute(:subscribed_user_ids, all.uniq)
    end

    def remove_subscription(list)
      update_attribute(
        :subscribed_user_ids,
        subscribed_user_ids - clean_subscription_list(list)
      )
    end

    private

    def clean_subscription_list(list)
      list = list.join(',') if list.respond_to?(:join)
      list.to_s.split(',').map(&:strip).map(&:downcase).reject(&:blank?)
    end
  end
end
