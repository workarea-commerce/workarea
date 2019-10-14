---
title: Test a Credit Card Transaction
excerpt: How to use the default "bogus" gateway to test credit card transactions in development environments
created_at: 2018/07/31
---

Test a Credit Card Transaction
======================================================================

By default, Workarea configures the credit card tender type to use a bogus gateway in development environments. This gateway, an instance of [`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway), provides the following useful features for local development and testing:

* Use credit card number ending in 1 for success, 2 for exception, and anything else for error
* Use amount ending in 00 for success, 05 for failure, and anything else for exception

If your application is using a different gateway in Development, consult the documentation for your gateway.
