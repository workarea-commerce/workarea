---
title: Implementing Payment Tender Types
excerpt: TODO
created_at: 2019/10/25
---

Implementing Payment Tender Types
======================================================================

You can implement [payment tender types](/articles/payment-tender-types.html), such as the incomplete [credit card tender type](/articles/implement-the-credit-card-tender-type.html) or add new tender types, either [primary tender types](/articles/implement-a-primary-tender-type.html) or [advance payment tender types](/articles/implement-an-advance-payment-tender-type.html).

To do so, you must understand the various concerns of a tender type, which are:

* [Gateways](#gateways_1)
* [Commerce Cloud Proxy](#commerce-cloud-proxy_4)
* [Credit Card Tokenization](#credit-card-tokenization_5)
* [Tender Type Definition](#tender-type-definition_6)
* [Payment Integration](#payment-integration_7)
* [Operation Implementations](#operation-implementations_8)
* [Storefront Integration](#storefront-integration_9)
* [Admin Integration](#admin-integration_10)


Gateways
----------------------------------------------------------------------

A payment tender type relies on one or more gateways.

A gateway is an object that's responsible for processing a payment of that tender type.

Add concrete examples of initializing and using a gateway object to clarify.

Lots of variation in how Gateways are used.
Not practical to prescribe one way of doing it.
But can discuss patterns and anti-patterns.


### Gateway Patterns

Behind the gateway can be a remote service or a local subsystem.

It's class could be a subclass of [`ActiveMerchant::Billing::Gateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/Gateway).
Could be some other class provided by a library.
Could be a class defined in the Workarea app or plugin.
If you're own class, should provide automated tests.

A tender type often relies on multiple gateways, which may be of different classes, or my be instances of the same class in different states.
Gateway objects are often stateful, accepting different arguments when initialized and/or allowing assignment of values after initialization.
Those that talk to another service often require credentials, which are usually passed in through Rails secrets.

Init different gateways for different contexts/uses.
Consider local development, manual testing in QA/staging, automated testing, and production use cases.
Expand on this.
Bogus gateways vs gateways configured for testing (sandboxes) -- local vs remote.

How the gateway is accessed by the objects that need to access it.
This usually means [operation implementations](#operation-implementations_8) and automated tests.
And credit card tokenization in the case of the credit card tender type.

Planned for Workarea 3.6 is a new design for this, but until then, the best practice is ...
For operation implementations and credit card tokenization, mix in a module that defines the `#gateway` method, ensuring that it inits a new instance each time it's called.
For automated tests when a remote service is involved, talk to the real service to get all the tests passing, recording all the responses as [vcr](https://rubygems.org/gems/vcr) cassettes and commit them.
Then, like you did for operation implementations, implement a module that implements `#gateway`, using the same class as you used when recording the cassettes, but you can init the instance with dummy credentials, since it won't actually reach out to the service when running the tests.

Examples of Rails secrets:

```yaml
# config/secrets.yml
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  braintree:
    merchant_id: foo
    public_key: bar
    private_key: baz
    merchant_account_id: qux
```

Which you can confirm by opening a production console:

```shell
$ RAILS_ENV=production bin/rails c
```

or, for Commerce Cloud:

```shell
$ workarea production console
```

And viewing the braintree secrets:

```ruby
puts Rails.application.secrets.braintree
# {:merchant_id=>"foo", :public_key=>"bar", :private_key=>"baz", :merchant_account_id=>"qux"}
```

```yaml
# config/secrets.yml
development:
  secret_key_base: 836fa3
test:
  secret_key_base: 5a3781
  paypal:
    login: sandbox_login
    password: sandbox_password
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  paypal:
    login: production_login
    password: production_password
```

```shell
$ RAILS_ENV=development bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
(blank)

$ RAILS_ENV=test bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
{:login=>"sandbox_login", :password=>"sandbox_password"}

$ RAILS_ENV=production bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
{:login=>"production_login", :password=>"production_password"}
```

[`Rails::Application#secrets`](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets)


### Gateway Anti-Patterns

An antipattern you will see until Workarea 3.6 is memoizing a gateway object, usually initializing it at boot and keeping it in configuration and re-using it.
This doesn't work with multi site.
Instead init a new gateway object every time you access it, as described above.

Stubbing responses from a service (in automated tests) is another anti-pattern.
Use vcr as described above.


Commerce Cloud Proxy
----------------------------------------------------------------------

If you're using Workarea Commerce Cloud, and you're using a gateway that's backed by a remote service, you have to add the endpoint(s) for the payment service provider to the proxy configuration, which will enable outgoing requests to the service.

Edit the proxy configuration using the _edit_ command from the [Workarea CLI](/cli.html).
See [Workarea CLI Cheat Sheet, Edit](/cli.html#edit).


Credit Card Tokenization
----------------------------------------------------------------------

applies to credit card tender type only


Tender Type Definition
----------------------------------------------------------------------

does not apply to credit card tender type


Payment Integration
----------------------------------------------------------------------

does not apply to credit card tender type


Operation Implementations
----------------------------------------------------------------------


Storefront Integration
----------------------------------------------------------------------

does not apply to credit card tender type


Admin Integration
----------------------------------------------------------------------

does not apply to credit card tender type
