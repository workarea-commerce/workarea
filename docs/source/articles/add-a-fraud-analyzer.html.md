---
title: Add a Fraud Analyzer
excerpt: This page will guide you through a step-by-step process of adding a custom fraud analyzer to evaluate orders.
---

# Add a Fraud Analyzer

Workarea provides a default fraud analyzer which will make no decision of the fraudulence of an order. This analyzer will return a `no decision` by default and is meant to be placeholder until retailer specific rules can be put into place.

Fraud decisions are made **before** payment is collected, meaning no payment actions will be taken if the order is found to be fraudulent. Orders deemed fraudulent are not able to be placed.

After the analyzer runs, `Order#fraud_decision` returns an embedded [`Order::FraudDecision`](https://github.com/workarea-commerce/workarea/blob/v3.5.4/core/app/models/workarea/order/fraud_decision.rb) document that stores the fraud decision and related information.

## Create a custom analyzer class

Create a new fraud analyzer class to add custom fraud rules to your application. Workarea uses the No Decision analyzer by default located at `Workarea::Checkout::Fraud::NoDecisionAnalyzer`. It is recommended that you create a new class to check for fraud rather than decorate the existing no decision analyzer.

Consider the following example fraud check: Decline any order greater than $1,000.00 and whose products are all digital.

This could be accomplished by adding the following class:

```ruby
#app/models/workarea/checkout/fraud/custom_analyzer.rb
module Workarea
  class Checkout
    module Fraud
      class CustomAnalyzer < Analyzer
        def make_decision
          if order.total_price > 1000.to_m && order.items.none?(&:shipping?)
            Workarea::Order::FraudDecision.new(
              decision: :declined,
              message: "Order exceeds price limit for an all digital cart contents"
            )
          else
            Workarea::Order::FraudDecision.new(
              decision: :approved,
              message: "Fraud checks passed"
            )
          end
        end
      end
    end
  end
end
```

Fraud analyzers must conform to the following:

* Inherit from `analyzer`
* Return an instance of `Workarea::Order::FraudDecision`
* Respond to `make_decision`

External API calls to a third party fraud service should be called in this class. The `FraudDecision` class has a field `response` which can store the response received back from the API, this is useful for debugging and reporting purposes.

## Update configuration

The configuration will now need to be updated to make use of the new custom fraud analyzer. Simply update the `fraud_analyzer` configuration value in your host application.

```ruby
config.fraud_analyzer = 'Workarea::Checkout::Fraud::CustomAnalyzer'
```

It is encouraged that you write the relevant system and unit tests to ensure that your fraud analyzer is functioning as expected.
