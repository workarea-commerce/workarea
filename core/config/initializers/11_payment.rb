if Rails.env.test? || Rails.env.development?
  ActiveMerchant::Billing::Base.mode = :test
end

if Workarea.config.gateways.credit_card.blank?
  Workarea.config.gateways.credit_card = ActiveMerchant::Billing::BogusGateway.new
  ActiveMerchant::Billing::Base.mode = :test
end
