module Workarea
  class PricingOverrideParams
    attr_reader :params, :user

    def initialize(params, user = nil)
      @params = params.with_indifferent_access
      @user = user
    end

    def to_h
      flip_adjustment_values
      set_created_by
      params
    end

    def flip_adjustment_values
      if params[:subtotal_adjustment].present?
        params[:subtotal_adjustment] = params[:subtotal_adjustment].to_f * -1
      end

      if params[:shipping_adjustment].present?
        params[:shipping_adjustment] = params[:shipping_adjustment].to_f * -1
      end
    end

    def set_created_by
      return unless user.present?
      params.merge!(created_by_id: user.id)
    end
  end
end
