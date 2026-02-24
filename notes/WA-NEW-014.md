# WA-NEW-014: Plugin modernization inventory + tracking (workarea-commerce/*)

## Goal
Establish a lightweight inventory of Workarea plugin repositories under the **workarea-commerce** GitHub org, and propose a consistent tracking approach for modernization work across those repos.

## Scope / Notes
- Inventory focuses on repositories that start with **`workarea-`**.
- No repos in this set are currently marked **archived** (as of generation time).
- Fields captured: repo link, coarse category, risk level, complexity estimate, default branch, last GitHub update date.

> This is intended as a starting point for triage/prioritization and tracking, not a deep technical audit of each plugin.

## Summary counts
Total repos inventoried: **117**

- Auth & Security: 6
- Commerce Features: 14
- Dev Tools & Ops: 13
- Marketing & CX Integrations: 14
- Other: 13
- Payments: 17
- Platform & Extensibility: 3
- Search & Content: 8
- Shipping & Fulfillment: 10
- Tax: 2
- Themes & UI: 17

## Proposed tracking approach (lightweight)
Recommended minimum viable tracking that scales across many repos:

1. **Keep this inventory doc in `workarea`** (this repo) as the canonical index.
2. Add/standardize a label in plugin repos, e.g. **`modernization`** (and optionally **`needs-triage`**, **`blocked`**).
3. For each plugin that enters active work, create a **single modernization “umbrella” issue** in that plugin repo with a standard checklist:
   - Ruby/Rails compatibility target (e.g. Ruby 3.x, Rails 7.x)
   - Dependency bumps (gems, JS, CI)
   - Test suite green
   - Release process (versioning + changelog)
   - Upgrade notes
4. In `workarea` (this repo), create/maintain one **tracking issue** (or use the existing WA-NEW-014 issue) with links to the plugin umbrella issues.

Optional next step (if the org wants a single pane of glass):
- Create a **GitHub Project** (org-level) called “Plugin Modernization” and add each plugin umbrella issue to it.

## Inventory
| Repo | Category | Risk | Complexity | Default branch | Last updated |
| ---- | -------- | ---- | ---------- | -------------- | ------------ |
| [workarea-a11y](https://github.com/workarea-commerce/workarea-a11y) | Auth & Security | Medium | Low | master | 2020-04-15 |
| [workarea-address-verification](https://github.com/workarea-commerce/workarea-address-verification) | Auth & Security | Medium | Low | master | 2021-05-05 |
| [workarea-aws-sso](https://github.com/workarea-commerce/workarea-aws-sso) | Auth & Security | Medium | Low | main | 2021-04-14 |
| [workarea-basic-auth](https://github.com/workarea-commerce/workarea-basic-auth) | Auth & Security | Medium | Low | master | 2020-01-03 |
| [workarea-gdpr](https://github.com/workarea-commerce/workarea-gdpr) | Auth & Security | Medium | Low | master | 2020-12-14 |
| [workarea-google-address-autocomplete](https://github.com/workarea-commerce/workarea-google-address-autocomplete) | Auth & Security | Medium | Low | master | 2020-01-27 |
| [workarea-b2b](https://github.com/workarea-commerce/workarea-b2b) | Commerce Features | Medium | High | master | 2020-11-04 |
| [workarea-multi-site](https://github.com/workarea-commerce/workarea-multi-site) | Commerce Features | Medium | High | master | 2020-06-17 |
| [workarea-subscriptions](https://github.com/workarea-commerce/workarea-subscriptions) | Commerce Features | Medium | High | master | 2021-01-29 |
| [workarea-gift-cards](https://github.com/workarea-commerce/workarea-gift-cards) | Commerce Features | Medium | Low | master | 2024-12-17 |
| [workarea-gift-wrapping](https://github.com/workarea-commerce/workarea-gift-wrapping) | Commerce Features | Medium | Low | master | 2020-01-03 |
| [workarea-inventory-notifications](https://github.com/workarea-commerce/workarea-inventory-notifications) | Commerce Features | Medium | Low | master | 2020-12-14 |
| [workarea-legacy-orders](https://github.com/workarea-commerce/workarea-legacy-orders) | Commerce Features | Medium | Low | master | 2020-10-29 |
| [workarea-package-products](https://github.com/workarea-commerce/workarea-package-products) | Commerce Features | Medium | Low | master | 2020-12-14 |
| [workarea-product-bundles](https://github.com/workarea-commerce/workarea-product-bundles) | Commerce Features | Medium | Low | master | 2024-06-10 |
| [workarea-quick-order](https://github.com/workarea-commerce/workarea-quick-order) | Commerce Features | Medium | Low | master | 2020-01-23 |
| [workarea-quotes](https://github.com/workarea-commerce/workarea-quotes) | Commerce Features | Medium | Low | master | 2020-12-02 |
| [workarea-returns](https://github.com/workarea-commerce/workarea-returns) | Commerce Features | Medium | Low | master | 2020-09-02 |
| [workarea-save-for-later](https://github.com/workarea-commerce/workarea-save-for-later) | Commerce Features | Medium | Low | master | 2020-12-14 |
| [workarea-wish-lists](https://github.com/workarea-commerce/workarea-wish-lists) | Commerce Features | Medium | Low | master | 2020-12-14 |
| [workarea-commerce-cloud](https://github.com/workarea-commerce/workarea-commerce-cloud) | Dev Tools & Ops | Low | High | master | 2020-11-11 |
| [workarea-cli-plugin-ops](https://github.com/workarea-commerce/workarea-cli-plugin-ops) | Dev Tools & Ops | Low | Low | master | 2020-09-11 |
| [workarea-demo](https://github.com/workarea-commerce/workarea-demo) | Dev Tools & Ops | Low | Low | master | 2020-05-28 |
| [workarea-demo-data](https://github.com/workarea-commerce/workarea-demo-data) | Dev Tools & Ops | Low | Low | master | 2020-10-19 |
| [workarea-demo-operator](https://github.com/workarea-commerce/workarea-demo-operator) | Dev Tools & Ops | Low | Low | master | 2020-01-23 |
| [workarea-mach](https://github.com/workarea-commerce/workarea-mach) | Dev Tools & Ops | Low | Low | master | 2020-01-03 |
| [workarea-magento-data-importer](https://github.com/workarea-commerce/workarea-magento-data-importer) | Dev Tools & Ops | Low | Low | master | 2020-02-21 |
| [workarea-ops](https://github.com/workarea-commerce/workarea-ops) | Dev Tools & Ops | Low | Low | main | 2020-11-11 |
| [workarea-ops-documentation](https://github.com/workarea-commerce/workarea-ops-documentation) | Dev Tools & Ops | Low | Low | master | 2024-05-31 |
| [workarea-scaling-operator](https://github.com/workarea-commerce/workarea-scaling-operator) | Dev Tools & Ops | Low | Low | main | 2021-10-06 |
| [workarea-shopify-migration](https://github.com/workarea-commerce/workarea-shopify-migration) | Dev Tools & Ops | Low | Low | master | 2020-02-21 |
| [workarea-site](https://github.com/workarea-commerce/workarea-site) | Dev Tools & Ops | Low | Low | main | 2023-11-09 |
| [workarea-upgrade](https://github.com/workarea-commerce/workarea-upgrade) | Dev Tools & Ops | Low | Low | master | 2020-08-28 |
| [workarea-ab-testing](https://github.com/workarea-commerce/workarea-ab-testing) | Marketing & CX Integrations | Medium | Low | master | 2020-01-23 |
| [workarea-bazaar-voice](https://github.com/workarea-commerce/workarea-bazaar-voice) | Marketing & CX Integrations | Medium | Low | master | 2020-07-15 |
| [workarea-emarsys](https://github.com/workarea-commerce/workarea-emarsys) | Marketing & CX Integrations | Medium | Low | master | 2020-01-29 |
| [workarea-facebook-login](https://github.com/workarea-commerce/workarea-facebook-login) | Marketing & CX Integrations | Medium | Low | master | 2020-01-03 |
| [workarea-google-analytics](https://github.com/workarea-commerce/workarea-google-analytics) | Marketing & CX Integrations | Medium | Low | master | 2020-02-04 |
| [workarea-google-product-feed](https://github.com/workarea-commerce/workarea-google-product-feed) | Marketing & CX Integrations | Medium | Low | master | 2020-06-25 |
| [workarea-google-tag-manager](https://github.com/workarea-commerce/workarea-google-tag-manager) | Marketing & CX Integrations | Medium | Low | master | 2020-06-25 |
| [workarea-listrak](https://github.com/workarea-commerce/workarea-listrak) | Marketing & CX Integrations | Medium | Low | master | 2020-09-16 |
| [workarea-mailchimp](https://github.com/workarea-commerce/workarea-mailchimp) | Marketing & CX Integrations | Medium | Low | master | 2020-06-22 |
| [workarea-salesforce-esp](https://github.com/workarea-commerce/workarea-salesforce-esp) | Marketing & CX Integrations | Medium | Low | master | 2020-01-22 |
| [workarea-segment-analytics](https://github.com/workarea-commerce/workarea-segment-analytics) | Marketing & CX Integrations | Medium | Low | master | 2020-01-27 |
| [workarea-share](https://github.com/workarea-commerce/workarea-share) | Marketing & CX Integrations | Medium | Low | master | 2020-12-17 |
| [workarea-yotpo](https://github.com/workarea-commerce/workarea-yotpo) | Marketing & CX Integrations | Medium | Low | master | 2020-08-14 |
| [workarea-zendesk](https://github.com/workarea-commerce/workarea-zendesk) | Marketing & CX Integrations | Medium | Low | master | 2020-01-03 |
| [workarea-browse-option](https://github.com/workarea-commerce/workarea-browse-option) | Other | Low | Low | master | 2020-11-18 |
| [workarea-category-overview](https://github.com/workarea-commerce/workarea-category-overview) | Other | Low | Low | master | 2020-01-23 |
| [workarea-currency-display](https://github.com/workarea-commerce/workarea-currency-display) | Other | Low | Low | master | 2020-01-23 |
| [workarea-data-file-scheduling](https://github.com/workarea-commerce/workarea-data-file-scheduling) | Other | Low | Low | master | 2020-01-23 |
| [workarea-elastic-apm](https://github.com/workarea-commerce/workarea-elastic-apm) | Other | Low | Low | master | 2020-01-23 |
| [workarea-email-signup-popup](https://github.com/workarea-commerce/workarea-email-signup-popup) | Other | Low | Low | master | 2020-01-27 |
| [workarea-give-x](https://github.com/workarea-commerce/workarea-give-x) | Other | Low | Low | master | 2020-01-03 |
| [workarea-product-badges](https://github.com/workarea-commerce/workarea-product-badges) | Other | Low | Low | master | 2020-12-14 |
| [workarea-reviews](https://github.com/workarea-commerce/workarea-reviews) | Other | Low | Low | master | 2020-12-17 |
| [workarea-sentry](https://github.com/workarea-commerce/workarea-sentry) | Other | Low | Low | master | 2021-01-12 |
| [workarea-site-builder](https://github.com/workarea-commerce/workarea-site-builder) | Other | Low | Low | master | 2021-01-20 |
| [workarea-sitemaps](https://github.com/workarea-commerce/workarea-sitemaps) | Other | Low | Low | master | 2020-07-02 |
| [workarea-variant-list](https://github.com/workarea-commerce/workarea-variant-list) | Other | Low | Low | master | 2020-12-14 |
| [workarea-affirm](https://github.com/workarea-commerce/workarea-affirm) | Payments | High | Medium | master | 2020-11-12 |
| [workarea-afterpay](https://github.com/workarea-commerce/workarea-afterpay) | Payments | High | Medium | master | 2020-05-06 |
| [workarea-amazon-payments](https://github.com/workarea-commerce/workarea-amazon-payments) | Payments | High | Medium | master | 2020-01-03 |
| [workarea-authorize-cim](https://github.com/workarea-commerce/workarea-authorize-cim) | Payments | High | Medium | master | 2020-09-16 |
| [workarea-braintree](https://github.com/workarea-commerce/workarea-braintree) | Payments | High | Medium | master | 2020-08-21 |
| [workarea-checkoutdotcom](https://github.com/workarea-commerce/workarea-checkoutdotcom) | Payments | High | Medium | master | 2020-01-03 |
| [workarea-cyber-source](https://github.com/workarea-commerce/workarea-cyber-source) | Payments | High | Medium | master | 2020-01-03 |
| [workarea-forter](https://github.com/workarea-commerce/workarea-forter) | Payments | High | Medium | master | 2020-01-22 |
| [workarea-klarna](https://github.com/workarea-commerce/workarea-klarna) | Payments | High | Medium | master | 2020-12-22 |
| [workarea-kount](https://github.com/workarea-commerce/workarea-kount) | Payments | High | Medium | master | 2020-12-02 |
| [workarea-moneris](https://github.com/workarea-commerce/workarea-moneris) | Payments | High | Medium | master | 2020-01-23 |
| [workarea-payflow-pro](https://github.com/workarea-commerce/workarea-payflow-pro) | Payments | High | Medium | master | 2020-01-23 |
| [workarea-paypal](https://github.com/workarea-commerce/workarea-paypal) | Payments | High | Medium | master | 2020-08-18 |
| [workarea-payware-connect](https://github.com/workarea-commerce/workarea-payware-connect) | Payments | High | Medium | master | 2020-01-22 |
| [workarea-stripe](https://github.com/workarea-commerce/workarea-stripe) | Payments | High | Medium | master | 2020-09-06 |
| [workarea-worldpay-xml](https://github.com/workarea-commerce/workarea-worldpay-xml) | Payments | High | Medium | master | 2020-01-03 |
| [workarea-zipco](https://github.com/workarea-commerce/workarea-zipco) | Payments | High | Medium | master | 2020-12-14 |
| [workarea-api](https://github.com/workarea-commerce/workarea-api) | Platform & Extensibility | Medium | High | master | 2023-12-13 |
| [workarea-circuit-breaker](https://github.com/workarea-commerce/workarea-circuit-breaker) | Platform & Extensibility | Medium | Medium | master | 2020-03-20 |
| [workarea-webhooks](https://github.com/workarea-commerce/workarea-webhooks) | Platform & Extensibility | Medium | Medium | master | 2020-01-03 |
| [workarea-blog](https://github.com/workarea-commerce/workarea-blog) | Search & Content | Low | Low | master | 2020-12-14 |
| [workarea-classic-search-autocomplete](https://github.com/workarea-commerce/workarea-classic-search-autocomplete) | Search & Content | Low | Low | master | 2020-12-14 |
| [workarea-content-search](https://github.com/workarea-commerce/workarea-content-search) | Search & Content | Low | Low | master | 2020-07-16 |
| [workarea-expandable-content-block](https://github.com/workarea-commerce/workarea-expandable-content-block) | Search & Content | Low | Low | master | 2020-01-03 |
| [workarea-product-documents](https://github.com/workarea-commerce/workarea-product-documents) | Search & Content | Low | Low | master | 2020-12-14 |
| [workarea-product-grid-content](https://github.com/workarea-commerce/workarea-product-grid-content) | Search & Content | Low | Low | master | 2021-01-13 |
| [workarea-product-videos](https://github.com/workarea-commerce/workarea-product-videos) | Search & Content | Low | Low | master | 2020-12-14 |
| [workarea-search-autocomplete](https://github.com/workarea-commerce/workarea-search-autocomplete) | Search & Content | Low | Low | master | 2024-04-29 |
| [workarea-global-e](https://github.com/workarea-commerce/workarea-global-e) | Shipping & Fulfillment | Medium | High | master | 2020-01-22 |
| [workarea-oms](https://github.com/workarea-commerce/workarea-oms) | Shipping & Fulfillment | Medium | High | master | 2020-12-01 |
| [workarea-orderbot](https://github.com/workarea-commerce/workarea-orderbot) | Shipping & Fulfillment | Medium | High | master | 2021-11-08 |
| [workarea-bopus](https://github.com/workarea-commerce/workarea-bopus) | Shipping & Fulfillment | Medium | Medium | master | 2020-11-13 |
| [workarea-flow-io](https://github.com/workarea-commerce/workarea-flow-io) | Shipping & Fulfillment | Medium | Medium | master | 2020-02-21 |
| [workarea-ship-station](https://github.com/workarea-commerce/workarea-ship-station) | Shipping & Fulfillment | Medium | Medium | master | 2020-01-03 |
| [workarea-shipping-estimation](https://github.com/workarea-commerce/workarea-shipping-estimation) | Shipping & Fulfillment | Medium | Medium | master | 2020-06-25 |
| [workarea-shipping-message](https://github.com/workarea-commerce/workarea-shipping-message) | Shipping & Fulfillment | Medium | Medium | master | 2020-06-17 |
| [workarea-split-shipping](https://github.com/workarea-commerce/workarea-split-shipping) | Shipping & Fulfillment | Medium | Medium | master | 2020-09-23 |
| [workarea-store-locations](https://github.com/workarea-commerce/workarea-store-locations) | Shipping & Fulfillment | Medium | Medium | master | 2020-06-25 |
| [workarea-avatax](https://github.com/workarea-commerce/workarea-avatax) | Tax | High | Medium | master | 2020-03-05 |
| [workarea-taxjar](https://github.com/workarea-commerce/workarea-taxjar) | Tax | High | Medium | master | 2020-09-10 |
| [workarea-accordions](https://github.com/workarea-commerce/workarea-accordions) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-clifton-theme](https://github.com/workarea-commerce/workarea-clifton-theme) | Themes & UI | Low | Low | master | 2020-07-16 |
| [workarea-filter-dropdowns](https://github.com/workarea-commerce/workarea-filter-dropdowns) | Themes & UI | Low | Low | master | 2020-01-03 |
| [workarea-haven-theme](https://github.com/workarea-commerce/workarea-haven-theme) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-hover-zoom](https://github.com/workarea-commerce/workarea-hover-zoom) | Themes & UI | Low | Low | master | 2020-01-03 |
| [workarea-jquery-magnify](https://github.com/workarea-commerce/workarea-jquery-magnify) | Themes & UI | Low | Low | master | 2020-01-03 |
| [workarea-jquery-zoom](https://github.com/workarea-commerce/workarea-jquery-zoom) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-nvy-theme](https://github.com/workarea-commerce/workarea-nvy-theme) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-one-theme](https://github.com/workarea-commerce/workarea-one-theme) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-product-quickview](https://github.com/workarea-commerce/workarea-product-quickview) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-slick-slider](https://github.com/workarea-commerce/workarea-slick-slider) | Themes & UI | Low | Low | master | 2020-04-14 |
| [workarea-slider-block](https://github.com/workarea-commerce/workarea-slider-block) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-styled-selects](https://github.com/workarea-commerce/workarea-styled-selects) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-super-hero](https://github.com/workarea-commerce/workarea-super-hero) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-swatches](https://github.com/workarea-commerce/workarea-swatches) | Themes & UI | Low | Low | master | 2020-12-14 |
| [workarea-theme](https://github.com/workarea-commerce/workarea-theme) | Themes & UI | Low | Low | master | 2020-01-03 |
| [workarea-vue](https://github.com/workarea-commerce/workarea-vue) | Themes & UI | Low | Low | master | 2020-01-23 |
