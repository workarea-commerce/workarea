---
title: Configure a Payment Gateway
excerpt: Workarea provides the following configurations for your payment gateway integration. See Integrate a Payment Gateway to learn more about integrating a payment gateway with Workarea.
---

# Configure a Payment Gateway

Workarea provides the following configurations for your payment gateway integration. See [Integrate a Payment Gateway](integrate-a-payment-gateway.html) to learn more about integrating a payment gateway with Workarea.

| Config | Description |
| --- | --- |
| `config.gateways.credit_card` | Set credit card gateway |
| `config.gateways.paypal` | Set Paypal gateway (if using the Paypal plugin) |
| `config.credit_card_issuers` | Map of ActiveMerchant credit card issuer to friendly display name of issuer. Used to display issuer name and issuer icon in views. Unknown values will display as titleized version of the ActiveMerchant key passed. |
| `config.tender_types` | The available tender types for purchase/refund, used in order to determine purchase precedence and in reverse for refund precedence |

your\_app/config/initializers/workarea.rb:

```
# ...

Workarea.configure do |config|

  # ...

  # Default bogus gateway
  config.gateways.credit_card = ActiveMerchant::Billing::BogusGateway.new

  # config.gateways.credit_card = ActiveMerchant::Billing::CyberSourceGateway.new(
  # login: 'XXXX',
  # password: 'XXXX',
  # test: true
  # )

  config.gateways.paypal = ActiveMerchant::Billing::PaypalExpressGateway.new(
    login: 'XXXX',
    password: 'XXXX',
    signature: 'XXXX'
  )

  credit_card_issuers = Hash.new { |hash, key| key.titleize }
  config.credit_card_issuers = credit_card_issuers.merge(
    'visa' => 'Visa',
    'diners_club' => "Diner's Club",
    'master' => 'MasterCard',
    'discover' => 'Discover',
    'american_express' => 'American Express',
    'bogus' => 'Test Card'
  )

  config.tender_types = [:store_credit, :credit_card]

  # ...

end
```


