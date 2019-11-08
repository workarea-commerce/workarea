---
title: Manually Test Credit Card Transactions
excerpt: How to manually test credit card transactions in your web browser, either in a local development environment or a QA/staging environment
created_at: 2019/11/05
---

Manually Test Credit Card Transactions
======================================================================

Individuals manually testing checkouts in their browsers—whether developers working in local development environments or dedicated testers working in QA/staging environments—need the ability to simulate credit card transactions that succeed, fail, and raise exceptions.
Fortunately, most credit card gateways provide features for this use case.

To use these features, first identify which credit card gateway is used in the environment in which you are testing, and then consult the documentation for that gateway.

For example, in an unmodified development environment, the credit card gateway is an instance of [`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway), which provides the following features for manual testing:

* Use credit card number ending in 1 for success, 2 for exception, and anything else for error
* Use amount ending in 00 for success, 05 for failure, and anything else for exception
