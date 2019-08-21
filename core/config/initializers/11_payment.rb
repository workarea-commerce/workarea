if Rails.env.test? || Rails.env.development?
  ActiveMerchant::Billing::Base.mode = :test
end

if Rails.env.test?
  Workarea.config.fraud_analyzer = "Workarea::Checkout::Fraud::TestAnalyzer"
end

if Workarea.config.gateways.credit_card.blank?
  Workarea.config.gateways.credit_card = ActiveMerchant::Billing::BogusGateway.new
  ActiveMerchant::Billing::Base.mode = :test
end
