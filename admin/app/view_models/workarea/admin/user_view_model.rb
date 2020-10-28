module Workarea
  module Admin
    class UserViewModel < ApplicationViewModel
      include CommentableViewModel
      include ActionView::Helpers::DateHelper

      def name
        if first_name.present? && last_name.present?
          "#{first_name} #{last_name}"
        else
          email
        end
      end

      def last_login
        if last_login_at.present?
          t(
            'workarea.admin.users.login.time_ago',
            period: time_ago_in_words(last_login_at)
          )
        else
          t('workarea.admin.users.login.never')
        end
      end

      def role
        if model.admin?
          t('workarea.admin.users.roles.admin')
        else
          t('workarea.admin.users.roles.customer')
        end
      end

      def last_impersonated_by
        return nil unless model.last_impersonated_by_id.present?
        @last_impersonated_by ||= User
                                    .where(id: model.last_impersonated_by_id)
                                    .first
      end

      def created_by
        return nil unless created_by_id.present?
        @created_by ||= UserViewModel.wrap(User.find(created_by_id))
      rescue Mongoid::Errors::DocumentNotFound
        @created_by ||= nil
      end

      def timeline
        @timeline ||= TimelineViewModel.wrap(model)
      end

      def payment_profile
        @payment_profile ||= Payment::Profile.lookup(
          PaymentReference.new(model)
        )
      end

      def orders
        return [] unless model.email.present?

        @orders ||= OrderViewModel.wrap(
          Order
            .placed
            .any_of({ email: model.email }, { user_id: model.id })
            .order_by([:placed_at, :desc])
            .limit(50)
        )
      end

      def insights
        @insights ||= Metrics::User.find_or_initialize_by(id: model.email)
      end

      def activity
        @activity ||= Recommendation::UserActivity.find_or_initialize_by(id: model.id)
      end

      def recent_products
        @recent_products ||= Catalog::Product.any_in(id: activity.product_ids)
      end

      def recent_categories
        @recent_categories ||= Catalog::Category.any_in(id: activity.category_ids)
      end

      def recent_searches
        activity.searches
      end

      def email_signup?
        @email_signup ||= Email.signed_up?(email)
      end
    end
  end
end
