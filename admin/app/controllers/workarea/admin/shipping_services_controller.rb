module Workarea
  class Admin::ShippingServicesController < Admin::ApplicationController
    required_permissions :settings
    before_action :find_service, except: :index

    def index
      @services = Shipping::Service.all.page(params[:page])
    end

    def show
      redirect_to edit_shipping_service_path(@service)
    end

    def new; end

    def edit; end

    def create
      build_rules

      if @service.save

        flash[:success] = t('workarea.admin.shipping_services.flash_messages.created')
        redirect_to shipping_services_path
      else
        render :new
      end
    end

    def update
      build_rules

      if @service.update_attributes(params[:service])
        flash[:success] = t('workarea.admin.shipping_services.flash_messages.saved')
        redirect_to shipping_services_path
      else
        render :edit
      end
    end

    def destroy
      @service.destroy
      flash[:success] = t('workarea.admin.shipping_services.flash_messages.removed')
      redirect_to shipping_services_path
    end

    private

    def find_service
      if params[:id].present?
        @service = Shipping::Service.find(params[:id])
      else
        @service = Shipping::Service.new(params[:service])
      end
    end

    def build_rules
      #this updates existing rates
      if params[:rates].present?
        params[:rates].each do |rate, attrs|
          if attrs[:price].present?
            attrs.each { |k,v| attrs[k] = nil if v.blank? }
            @service.rates.find(rate).update_attributes(attrs)
          end
        end
      end

      if params[:rates_to_remove].present?
        params[:rates_to_remove].each do |id|
          @service.rates.find(id).destroy
        end
      end

      #this adds new rates
      if params[:new_rates].present?
        Array(params[:new_rates]).flatten.each do |rate|
          if rate[:price].present?
            rate.delete_if { |k, v| v.blank? }
            @service.rates.build(rate)
          end
        end
      end
    end
  end
end
