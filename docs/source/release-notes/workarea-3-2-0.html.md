---
title: Workarea 3.2.0
excerpt: Displays dates and times in the Storefront and Admin using the time zone specified in Rails.application.config.time_zone.
---

# Workarea 3.2.0

## Uses Rails' Time Zone to Display all Dates & Times

Displays dates and times in the Storefront and Admin using the time zone specified in `Rails.application.config.time_zone`.

**Configure this time zone as appropriate for the retailer. If present, use the same value assigned to `Workarea.config.analytics_timezone`**

This change is an expansion of the [time zone changes introduced in Workarea 3.0.15](https://developer.workarea.com/workarea-3/guides/workarea-3-0-15#adds-configurable-time-zone-for-admin-analytics), which added `Workarea.config.analytics_timezone`.

Dates and times are still stored in UTC, so no database changes are required, however, **you must find and replace various Ruby API calls within your application to ensure the configured time zone is used for display**. [This article](https://developer.workarea.com/workarea-3/guides/workarea-3-0-15#adds-configurable-time-zone-for-admin-analytics) describes the necessary changes, but **the specific changes listed in the article are also duplicated below**.

Don't use:

- `Time.now`
- `Date.today`
- `Date.today.to_time`
- `Time.parse("2015-07-04 17:05:37")`
- `Time.strptime(string, "%Y-%m-%dT%H:%M:%S%z")`

Do use:

- `Time.current`
- `2.hours.ago`
- `Time.zone.today`
- `Date.current`
- `1.day.from_now`
- `Time.zone.parse("2015-07-04 17:05:37")`
- `Time.strptime(string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone`

To summarize, you must set `Rails.application.config.time_zone` to the time zone desired by the retailer and also find and replace within your application code according to the rules above.

### Issues

- [ECOMMERCE-5237](https://jira.tools.weblinc.com/browse/ECOMMERCE-5237)
- [ECOMMERCE-5311](https://jira.tools.weblinc.com/browse/ECOMMERCE-5311)

### Pull Requests

- [2811](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2811/overview)
- [2849](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2849/overview)

### Commits

- [3e79be19e935b96b17058da31a6b76f055423f0d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3e79be19e935b96b17058da31a6b76f055423f0d)
- [9538e315c6dec3aa0c55cab91875d02eef904f62](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9538e315c6dec3aa0c55cab91875d02eef904f62)
- [f45b894a1a33af2fd285d43218221363cb9ef8b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f45b894a1a33af2fd285d43218221363cb9ef8b5)
- [15a6d16285921e73597a51362fdb1233d90ead77](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/15a6d16285921e73597a51362fdb1233d90ead77)
- [ad2771eedf8719647d7df6ac3967861b0bd81abc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ad2771eedf8719647d7df6ac3967861b0bd81abc)

## Changes Password Requirements for Admins

In response to a PCI audit, changes password requirements for admin users. Within `Workarea::User::Passwords`, changes the required password strength for administrators to `:strong`. Updates administrator passwords throughout all seeds and tests to comply.

You will need to update admin passwords within your application code (seeds and tests) to conform to the new requirements. Production users are unaffected until their next password change, at which time the new rules will be enforced.

### Issues

- [ECOMMERCE-5629](https://jira.tools.weblinc.com/browse/ECOMMERCE-5629)

### Pull Requests

- [3078](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3078/overview)

### Commits

- [f88e89808adc8d03afe8094e24b57b0a32398190](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f88e89808adc8d03afe8094e24b57b0a32398190)
- [a85a3b0d85aeafe805c2fcb1134592f57c8059d8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a85a3b0d85aeafe805c2fcb1134592f57c8059d8)

## Updates Ruby Dependencies

Updates various Ruby dependencies, which removes `Fixnum` deprecation warnings and provides the benefits of various library fixes and improvements.

- Changes the minimum required Ruby version
- Changes the following library dependencies in Core: 
  - countries
  - easymon
  - faker
  - geocoder
  - image\_optim
  - image\_optim\_pack
  - inline\_svg
  - jbuilder
  - minitest
  - money-rails
  - redcarpet
  - sidekiq
  - sidekiq-unique-jobs
- Changes the following library dependencies in Testing: 
  - mocha
  - webmock

### Issues

- [ECOMMERCE-5424](https://jira.tools.weblinc.com/browse/ECOMMERCE-5424)
- [ECOMMERCE-5434](https://jira.tools.weblinc.com/browse/ECOMMERCE-5434)
- [ECOMMERCE-5440](https://jira.tools.weblinc.com/browse/ECOMMERCE-5440)
- [ECOMMERCE-5427](https://jira.tools.weblinc.com/browse/ECOMMERCE-5427)

### Commits

- [3297b03a946bf0c0656d498d6b2e590b58c1c21d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3297b03a946bf0c0656d498d6b2e590b58c1c21d)
- [a6c0c13720c61887a9cbebdf34be147c527207bf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a6c0c13720c61887a9cbebdf34be147c527207bf)
- [b33301e89801d64b9f84e03f9ad5f17ec0430b53](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b33301e89801d64b9f84e03f9ad5f17ec0430b53)
- [526bd2d5ef27be9207db2a94d22d92b3510f68a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/526bd2d5ef27be9207db2a94d22d92b3510f68a9)

## Converts All Remaining Specs to Tests

Converts all remaining RSpec specs within the platform to Minitest tests.

This change will add a substantial number of tests to your application's test suite. If this is a burden for your application (perhaps due to extensive customization), [skip or pass](testing.html#skipping-tests-resolving-conflicts) tests as necessary within your app.

- Adds MongoDB indexes as necessary (indexes are programmatically enforced in the Minitest test suite)
- Moves mixin tests from Workarea Testing to their own classes in Workarea Core
- Renames _spec_ to _test_ within some remaining filenames and pathnames (review the changes linked below)
- Removes all code to support and run specs

### Issues

- [ECOMMERCE-5224](https://jira.tools.weblinc.com/browse/ECOMMERCE-5224)
- [ECOMMERCE-5046](https://jira.tools.weblinc.com/browse/ECOMMERCE-5046)
- [ECOMMERCE-5327](https://jira.tools.weblinc.com/browse/ECOMMERCE-5327)
- [ECOMMERCE-5292](https://jira.tools.weblinc.com/browse/ECOMMERCE-5292)
- [ECOMMERCE-4772](https://jira.tools.weblinc.com/browse/ECOMMERCE-4772)

### Pull Requests

- [2795](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2795/overview)
- [2862](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2862/overview)
- [3027](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3027/overview)
- [3041](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3041/overview)
- [2842](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2842/overview)

### Commits

- [f1a6829c9fa9ead257560fd18e2a59c5a41606d3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f1a6829c9fa9ead257560fd18e2a59c5a41606d3)
- [51c8b1923b074b59e2a85ba19d18c575a2771cf5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/51c8b1923b074b59e2a85ba19d18c575a2771cf5)
- [e25f1243a7000a3f90d450b55c92dc787e105781](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e25f1243a7000a3f90d450b55c92dc787e105781)
- [61f500f8c636c92cfde083c50fc0251752312640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/61f500f8c636c92cfde083c50fc0251752312640)
- [0c9cb85ef60cda4de17a9e884fa12aa7f9dfbad2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0c9cb85ef60cda4de17a9e884fa12aa7f9dfbad2)
- [119af68818c7bee624df228ba9d06c794586105e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/119af68818c7bee624df228ba9d06c794586105e)
- [102d0fa4a2fe22b0d8d37edcf544df14107ac714](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/102d0fa4a2fe22b0d8d37edcf544df14107ac714)
- [aa14b9210620c1fbb8adbc84d001b335afeb7ca6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa14b9210620c1fbb8adbc84d001b335afeb7ca6)
- [b1d4356b8fb65c1fd86d607f827ba0f60de4ce91](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b1d4356b8fb65c1fd86d607f827ba0f60de4ce91)
- [5216437b01dcfe03092995ad90c7b875b16fce63](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5216437b01dcfe03092995ad90c7b875b16fce63)
- [e132c5c309c51c28f44d28495de4323ecec5d6fb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e132c5c309c51c28f44d28495de4323ecec5d6fb)
- [523a1f090681b0464c2616a03623c5fd2c7bb8d9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/523a1f090681b0464c2616a03623c5fd2c7bb8d9)
- [e3bae9d73c8b3a1aa1142f6e7c263436f354a640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e3bae9d73c8b3a1aa1142f6e7c263436f354a640)
- [2b6b8e017cbc15bf3dd143e03b6e38a472875e43](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2b6b8e017cbc15bf3dd143e03b6e38a472875e43)
- [97ee0620de5b61627474c5caa76e7c758488d380](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/97ee0620de5b61627474c5caa76e7c758488d380)
- [2eb9de0c3117d7572c3ba256d2c75be04877b2bf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2eb9de0c3117d7572c3ba256d2c75be04877b2bf)
- [8eb147df0a6e037e6cc0b1a26d4c6872ecc9b2d6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8eb147df0a6e037e6cc0b1a26d4c6872ecc9b2d6)
- [8969b60c24ad5a0224869ad32e2baa4a0d7c4f20](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8969b60c24ad5a0224869ad32e2baa4a0d7c4f20)
- [280f1367604256f84593ab451b0198822b2fae41](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/280f1367604256f84593ab451b0198822b2fae41)
- [efeb82e4a49c98403f7bfcafe9afe00fb5076812](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/efeb82e4a49c98403f7bfcafe9afe00fb5076812)
- [246cb7cd2fa47ba44d07eddcb3f3291a6448b25b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/246cb7cd2fa47ba44d07eddcb3f3291a6448b25b)
- [48a8bc4b686e17fe73cded813f0fc8d2a63a0222](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/48a8bc4b686e17fe73cded813f0fc8d2a63a0222)
- [7dff881050661c21e0dd688af2b4fed182291c77](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7dff881050661c21e0dd688af2b4fed182291c77)

## Adds Support for Split Shipping

Updates the base platform to support multiple shippings more completely, allowing plugins to more easily offer splitting the items of an order across multiple shipping addresses. Supports gifting functionality in plugins.

- Adds Admin index page for shippings
- Adds Admin shipping view model
- Adds shippings to Admin order view model
- Enumerates shippings on the orders Admin screens
- Updates the pricing tax applier to account for multiple shippings
- Adds shippings to Storefront order view model
- Adds Storefront shipping view model
- Adds append points in the Storefront
- Updates packaging service to account for multiple shippings
- Modifies Core and Storefront checkout code to support multiple shippings
- Improves extensibility of checkout to support plugins that support multiple shippings

### Issues

- [ECOMMERCE-5254](https://jira.tools.weblinc.com/browse/ECOMMERCE-5254)
- [ECOMMERCE-5319](https://jira.tools.weblinc.com/browse/ECOMMERCE-5319)
- [ECOMMERCE-5527](https://jira.tools.weblinc.com/browse/ECOMMERCE-5527)
- [ECOMMERCE-5534](https://jira.tools.weblinc.com/browse/ECOMMERCE-5534)
- [ECOMMERCE-5530](https://jira.tools.weblinc.com/browse/ECOMMERCE-5530)

### Pull Requests

- [2827](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2827/overview)
- [2858](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2858/overview)
- [2978](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2978/overview)
- [2950](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2950/overview)
- [2965](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2965/overview)
- [3012](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3012/overview)
- [3019](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3019/overview)
- [3021](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3021/overview)

### Commits

- [d7940aa6912ce420452a99a14121b67d7898a36a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d7940aa6912ce420452a99a14121b67d7898a36a)
- [f70a750ac0ca7f2561031a6c8941f2d5fcf855e9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f70a750ac0ca7f2561031a6c8941f2d5fcf855e9)
- [4ae81b7a4998837a8b3fc26bea3801f81ec485e5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4ae81b7a4998837a8b3fc26bea3801f81ec485e5)
- [3d7671e864c48dd35c468b70a0fa8ec4eaf0ccfd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3d7671e864c48dd35c468b70a0fa8ec4eaf0ccfd)
- [2177208b09bbcdc0addfc16783254cdef4386f19](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2177208b09bbcdc0addfc16783254cdef4386f19)
- [53858a5fbc2ff89bbf29b134a09001238ea8edc9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/53858a5fbc2ff89bbf29b134a09001238ea8edc9)
- [f620be94b1adb7c87a92d5d7cabbe88b7fed2483](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f620be94b1adb7c87a92d5d7cabbe88b7fed2483)
- [ce0eb9a1ea96bff2f5d525fe32e44caac0b54726](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ce0eb9a1ea96bff2f5d525fe32e44caac0b54726)
- [9f27b938a7946677f8b693b2631ad75a853033e8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9f27b938a7946677f8b693b2631ad75a853033e8)
- [1a5706f32db489e8529b8dfa1030c04464aba410](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a5706f32db489e8529b8dfa1030c04464aba410)
- [015930f23a9d3f299f4306b701aa22bd6c1e2b9b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/015930f23a9d3f299f4306b701aa22bd6c1e2b9b)
- [3bc9166ea1f9d78ed20778d13d987d59e35a0e91](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3bc9166ea1f9d78ed20778d13d987d59e35a0e91)
- [6f49764005d60e9fefd078e35cf10b933ba17eb9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6f49764005d60e9fefd078e35cf10b933ba17eb9)
- [95181da9e58f21e6505a0a296e767343d60f6fc9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/95181da9e58f21e6505a0a296e767343d60f6fc9)
- [c5203aca840c3b6bd1a774835fcc1a74c2c2c991](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c5203aca840c3b6bd1a774835fcc1a74c2c2c991)
- [7756338f6f7479c2600b6eb159524de08b3f7ee2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7756338f6f7479c2600b6eb159524de08b3f7ee2)
- [f7b5dd73a62ee1bfe05bcbf2cd05bc0d2a3ba185](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f7b5dd73a62ee1bfe05bcbf2cd05bc0d2a3ba185)
- [bcd6a537f17a8a12f6af2c998fb842aaacb35bf6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bcd6a537f17a8a12f6af2c998fb842aaacb35bf6)

## Converts Admin Indexes to Tables

Continuing a change introduced in 3.1, uses tables instead of summaries within all Admin index pages.

- Adds `.index-table` component
- Adds `.svg-icon--link-color` component modifier
- Adds `.link--no-underline` to the Admin typography layer
- Adds helper `Workarea::Admin::IconsHelper`

### Issues

- [ECOMMERCE-5201](https://jira.tools.weblinc.com/browse/ECOMMERCE-5201)
- [ECOMMERCE-5147](https://jira.tools.weblinc.com/browse/ECOMMERCE-5147)
- [ECOMMERCE-5303](https://jira.tools.weblinc.com/browse/ECOMMERCE-5303)
- [ECOMMERCE-5353](https://jira.tools.weblinc.com/browse/ECOMMERCE-5353)
- [ECOMMERCE-5397](https://jira.tools.weblinc.com/browse/ECOMMERCE-5397)
- [ECOMMERCE-5398](https://jira.tools.weblinc.com/browse/ECOMMERCE-5398)
- [ECOMMERCE-5511](https://jira.tools.weblinc.com/browse/ECOMMERCE-5511)
- [ECOMMERCE-5400](https://jira.tools.weblinc.com/browse/ECOMMERCE-5400)

### Pull Requests

- [2826](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2826/overview)
- [2837](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2837/overview)
- [2864](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2864/overview)
- [2882](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2882/overview)
- [2898](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2898/overview)
- [2946](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2946/overview)
- [2976](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2976/overview)
- [2911](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2911/overview)

### Commits

- [07259151aebd62e076429c257b1691d041ac0374](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/07259151aebd62e076429c257b1691d041ac0374)
- [c9554e44bb3be70761d73b37aadfec68660cdf02](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c9554e44bb3be70761d73b37aadfec68660cdf02)
- [e08cd29f6d50e4c60d0ff4a6cc462651040eec27](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e08cd29f6d50e4c60d0ff4a6cc462651040eec27)
- [9af386a05b2669260fb30f30a85300b3b0f5a020](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9af386a05b2669260fb30f30a85300b3b0f5a020)
- [cad1acf942e7daa68c104608a16d9864854a3c48](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cad1acf942e7daa68c104608a16d9864854a3c48)
- [838487f49bb245e38f6844c45e9196bd45ebf0c5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/838487f49bb245e38f6844c45e9196bd45ebf0c5)
- [5045ccc96cc1f39c5554dffa6a3f9a730db49317](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5045ccc96cc1f39c5554dffa6a3f9a730db49317)
- [ebea67af4f1df9a0aa9103cf15e0bcd190cb88bd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ebea67af4f1df9a0aa9103cf15e0bcd190cb88bd)
- [1feda8a9ead8f7ca37d2d7bf987cfe361dccfed9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1feda8a9ead8f7ca37d2d7bf987cfe361dccfed9)
- [94b9c0dca1ba11e75079d363a54b81430f1b4a43](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/94b9c0dca1ba11e75079d363a54b81430f1b4a43)
- [03d0fa6cd46f12b2e67d4d91a00c532bc727096c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/03d0fa6cd46f12b2e67d4d91a00c532bc727096c)
- [14f4e571f04afd60688d87acfdc341725900003a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/14f4e571f04afd60688d87acfdc341725900003a)
- [99a025157a385e97d0e5836aa230b469177cceb0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/99a025157a385e97d0e5836aa230b469177cceb0)
- [d30cf291ba44f50520d52dcb0ba3b378bf99b56d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d30cf291ba44f50520d52dcb0ba3b378bf99b56d)
- [6acb98e8a48768991b336c861dd4e372ff579e21](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6acb98e8a48768991b336c861dd4e372ff579e21)
- [5edbef4816bb24dd86f6f8c0de0b2ba2ea22cd28](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5edbef4816bb24dd86f6f8c0de0b2ba2ea22cd28)
- [3dcbd7e3500932fdb9e637e0195164926657ce05](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3dcbd7e3500932fdb9e637e0195164926657ce05)
- [0ee0d2ae4edba67d5949371b0dcffd80c8c6ffc4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0ee0d2ae4edba67d5949371b0dcffd80c8c6ffc4)
- [ac8d9080be70d980db756387f0fcd36bae07d635](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ac8d9080be70d980db756387f0fcd36bae07d635)

## Adds Releases Index Page in Admin

Adds an Admin index page for releases, which takes over as the “landing page” for releases in the Admin (replacing the releases calendar in this role). The releases calendar and index link to each other.

### Issues

- [ECOMMERCE-5498](https://jira.tools.weblinc.com/browse/ECOMMERCE-5498)
- [ECOMMERCE-5599](https://jira.tools.weblinc.com/browse/ECOMMERCE-5599)

### Pull Requests

- [3007](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3007/overview)
- [3036](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3036/overview)
- [3038](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3038/overview)

### Commits

- [84ad2473459f3c51831b47a4a385dbc32845926b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/84ad2473459f3c51831b47a4a385dbc32845926b)
- [3fbaa4032a0a976ca56b5fd72e34f6bb0383a90d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3fbaa4032a0a976ca56b5fd72e34f6bb0383a90d)
- [92ed3f79d4390853045faab6c6bbf6c948d91bfe](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/92ed3f79d4390853045faab6c6bbf6c948d91bfe)
- [4a17251f6c1c482b4adcca07a4d75cb19777f149](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4a17251f6c1c482b4adcca07a4d75cb19777f149)
- [ecb9deabb8c5953bfcf7e7e1aa0c3be45adde441](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ecb9deabb8c5953bfcf7e7e1aa0c3be45adde441)
- [df72bd535d4316cd5b96f7a65f1ea741d39a1117](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/df72bd535d4316cd5b96f7a65f1ea741d39a1117)

## Adds Product Insights Content Block Type

Adds a new content block type, “Product Insights”, which displays a dynamically generated list of “Top Products” or “Trending Products”, derived from Workarea analytics for the application.

- Adds `Workarea.config.product_insights_count`, which defaults to `6`
- Adds `.product-insights-content-block` component to the Storefront
- Adds `Storefront::ContentBlocks::ProductInsightsViewModel`
- Adds MongoDB index for `active` on `Workarea::Releasable`

### Issues

- [ECOMMERCE-5203](https://jira.tools.weblinc.com/browse/ECOMMERCE-5203)
- [ECOMMERCE-5374](https://jira.tools.weblinc.com/browse/ECOMMERCE-5374)
- [ECOMMERCE-5372](https://jira.tools.weblinc.com/browse/ECOMMERCE-5372)
- [ECOMMERCE-5376](https://jira.tools.weblinc.com/browse/ECOMMERCE-5376)

### Pull Requests

- [2841](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2841/overview)
- [2873](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2873/overview)
- [2869](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2869/overview)
- [2906](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2906/overview)

### Commits

- [c6bbc38f327b629f7a56f05648680249ca62d594](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c6bbc38f327b629f7a56f05648680249ca62d594)
- [357cf163c82ba98c655bef387d040a58577d78a2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/357cf163c82ba98c655bef387d040a58577d78a2)
- [b23c295fbb4e90108c7243f96c8248dd88b3ddba](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b23c295fbb4e90108c7243f96c8248dd88b3ddba)
- [cf11464ccbb4528d3d99ff5eb9fb53f37615f2b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cf11464ccbb4528d3d99ff5eb9fb53f37615f2b7)
- [d8adcd26cad58377ce5aa3d8b32ca9d753989744](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d8adcd26cad58377ce5aa3d8b32ca9d753989744)
- [ee755b74f6a512ff1a9df61879c2e899f57929d5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee755b74f6a512ff1a9df61879c2e899f57929d5)
- [1a730f240fb9896931e10cbd1253e6ff45c22593](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a730f240fb9896931e10cbd1253e6ff45c22593)
- [9a28b27ea3188c8a4f2dae252a261a4cbde4a9a8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a28b27ea3188c8a4f2dae252a261a4cbde4a9a8)

## Improves Presentation of Orders & User Management in Storefront

Applies various improvements to the Storefront views listed below. These changes improve the default display of these Storefront area so that fewer customizations are required. The changes also support other changes in Workarea 3.2 and various plugins.

In general, the changes improve the use of grids, tables, and headings, and make use of the new `.box` component. The following views are those most affected. Some additional changes are noted.

- _orders/\_summary_ - supports multiple shippings and refunds
- _users/orders/show_
- _checkouts/confirmation_
- _carts/show_
- _users/accounts/show_ - moves append point for easier extension

Notable API changes:

- Adds `$light-gray` color
- Enables `.grid--large` in grid configuration
- Improves base `table` styles
- Adds `.box` component
- Modifies `.button`, `.data-card`, `.style-guide`, `.table`, and `.text-box` components

### Issues

- [ECOMMERCE-5356](https://jira.tools.weblinc.com/browse/ECOMMERCE-5356)
- [ECOMMERCE-5464](https://jira.tools.weblinc.com/browse/ECOMMERCE-5464)
- [ECOMMERCE-5506](https://jira.tools.weblinc.com/browse/ECOMMERCE-5506)
- [ECOMMERCE-5526](https://jira.tools.weblinc.com/browse/ECOMMERCE-5526)
- [ECOMMERCE-5592](https://jira.tools.weblinc.com/browse/ECOMMERCE-5592)
- [ECOMMERCE-5623](https://jira.tools.weblinc.com/browse/ECOMMERCE-5623)
- [ECOMMERCE-5301](https://jira.tools.weblinc.com/browse/ECOMMERCE-5301)
- [ECOMMERCE-5208](https://jira.tools.weblinc.com/browse/ECOMMERCE-5208)

### Pull Requests

- [2918](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2918/overview)
- [2947](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2947/overview)
- [2962](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2962/overview)
- [3022](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3022/overview)
- [3032](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3032/overview)
- [3034](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3034/overview)
- [2840](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2840/overview)
- [2777](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2777/overview)

### Commits

- [eb7110048b033428a32154c2474059d1dbcf3768](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7110048b033428a32154c2474059d1dbcf3768)
- [b49dc4669cb02f9f27a8f78757b9ffc00e3f1449](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b49dc4669cb02f9f27a8f78757b9ffc00e3f1449)
- [7ee542c920a977730afe122d31d6ea4664dfee3c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7ee542c920a977730afe122d31d6ea4664dfee3c)
- [d6bc41b50232867f670b11248b42f4b5d0d92f3f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d6bc41b50232867f670b11248b42f4b5d0d92f3f)
- [85bd4974542b03b4fc30cf87b7f20cd5873fac51](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/85bd4974542b03b4fc30cf87b7f20cd5873fac51)
- [efb0087c46cb3c2bde24f9c11b3d8820e21a252b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/efb0087c46cb3c2bde24f9c11b3d8820e21a252b)
- [c41fa98348753045d94d20367a05ba7a564b7a65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c41fa98348753045d94d20367a05ba7a564b7a65)
- [40773713a13c0eb3d4990f7602c78e9cca3a0424](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/40773713a13c0eb3d4990f7602c78e9cca3a0424)
- [58c70670954c5086c868e95466b41950196a6a6a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/58c70670954c5086c868e95466b41950196a6a6a)
- [ffc45bf94690468a9bbf17c5cf0aa5d766abff2a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ffc45bf94690468a9bbf17c5cf0aa5d766abff2a)
- [a8e4cd6f36bf74fb5d89bc10363c1e98d496dfc8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a8e4cd6f36bf74fb5d89bc10363c1e98d496dfc8)
- [e924404ae51b59ed5a0e040ca22012b9e556e04d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e924404ae51b59ed5a0e040ca22012b9e556e04d)
- [fedcdf67007c20b00727c31b8710b0e46e16993f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fedcdf67007c20b00727c31b8710b0e46e16993f)
- [b3f8211bb0c986f5e58daa248a029e4349318a88](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3f8211bb0c986f5e58daa248a029e4349318a88)
- [a2556ee0b6670db69de8bd4e28dce2ec2f27fcaa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a2556ee0b6670db69de8bd4e28dce2ec2f27fcaa)
- [9b03a27191c9dc1067119d61faca3fa032723514](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9b03a27191c9dc1067119d61faca3fa032723514)
- [08ab849b3bfb77f01d04629f9a5205255c4b9b6d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08ab849b3bfb77f01d04629f9a5205255c4b9b6d)
- [78aa85dd687746ef4a69e7f5229cb41ec72fb28e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/78aa85dd687746ef4a69e7f5229cb41ec72fb28e)
- [410edc39205b2c0ede93846ee858f7665d658000](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/410edc39205b2c0ede93846ee858f7665d658000)
- [7d56aab63f9f40a60c755e5adc422e34f40c0e74](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7d56aab63f9f40a60c755e5adc422e34f40c0e74)
- [7576e03968af7cb88d5416d998218b2c33f24096](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7576e03968af7cb88d5416d998218b2c33f24096)

## Adds More Recommendations in the Storefront

Adds recommendations to Storefront empty cart, added-to-cart dialog, order confirmation, order summary, and account show.

### Issues

- [ECOMMERCE-5466](https://jira.tools.weblinc.com/browse/ECOMMERCE-5466)
- [ECOMMERCE-5467](https://jira.tools.weblinc.com/browse/ECOMMERCE-5467)
- [ECOMMERCE-5468](https://jira.tools.weblinc.com/browse/ECOMMERCE-5468)
- [ECOMMERCE-5439](https://jira.tools.weblinc.com/browse/ECOMMERCE-5439)

### Pull Requests

- [3020](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3020/overview)
- [2933](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2933/overview)

### Commits

- [27d11e853363dc6ee56652d755558691a1952a98](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/27d11e853363dc6ee56652d755558691a1952a98)
- [220a687b87d6a3899f5dadadd8f56dd8cdd316cd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/220a687b87d6a3899f5dadadd8f56dd8cdd316cd)
- [46192c98df11e2bbec3484b0fa8512708822ee67](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/46192c98df11e2bbec3484b0fa8512708822ee67)
- [70f214ed8fd48861731548acc7423b882718b93c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/70f214ed8fd48861731548acc7423b882718b93c)
- [b1545223c6b16fcaaac20ba4c2af76256587e90f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b1545223c6b16fcaaac20ba4c2af76256587e90f)
- [8b1af3f776178dd82989a88920ada565d803a0bf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8b1af3f776178dd82989a88920ada565d803a0bf)
- [71e16144792842d2098dcef5f901ebe26d7b5022](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/71e16144792842d2098dcef5f901ebe26d7b5022)

## Improves Storefront & Admin Searches

Applies various improvements to Storefront and Admin searches.

These changes do not require you to re-index your application, but many of the improvements will not take effect until you do.

Summary of Storefront changes:

- Improves spelling corrections
- Improves search suggestions
- Improves exact matching
- Improves redirecting

Summary of Admin changes:

- Improves keyword matching
- Adds searching payment transactions by order ID

Most significant API changes:

- Modifies `Search::QuerySuggestions`
- Adds `Weblinc.config.search_suggestion_min_doc_freq`
- Adds `Search::StorefrontSearch::ExactMatches` search middleware
- Removes `Search::StorefrontSearch::ProductAutoRedirect` search middleware from `Workarea.config.storefront_search_middleware` (but does not remove the class definition)

### Issues

- [ECOMMERCE-5182](https://jira.tools.weblinc.com/browse/ECOMMERCE-5182)
- [ECOMMERCE-5183](https://jira.tools.weblinc.com/browse/ECOMMERCE-5183)
- [ECOMMERCE-5184](https://jira.tools.weblinc.com/browse/ECOMMERCE-5184)
- [ECOMMERCE-5239](https://jira.tools.weblinc.com/browse/ECOMMERCE-5239)
- [ECOMMERCE-5475](https://jira.tools.weblinc.com/browse/ECOMMERCE-5475)

### Pull Requests

- [2768](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2768/overview)
- [2782](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2782/overview)
- [2784](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2784/overview)
- [2815](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2815/overview)

### Commits

- [ac600cc3681f2119ed1941730ab253c6f8901447](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ac600cc3681f2119ed1941730ab253c6f8901447)
- [f69000a88515304109324f903ec2bf40a1e1db8e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f69000a88515304109324f903ec2bf40a1e1db8e)
- [99e402b12b3d20a7946058f45376e0e5991444f9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/99e402b12b3d20a7946058f45376e0e5991444f9)
- [16d1fbce75c6e9ffbe100382f71a6695a2d55a52](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/16d1fbce75c6e9ffbe100382f71a6695a2d55a52)
- [6907dec68b402cd7df8f0e38938231a4b269270e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6907dec68b402cd7df8f0e38938231a4b269270e)
- [57a6507aec14d23a534cb854b385baafbbab1bca](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/57a6507aec14d23a534cb854b385baafbbab1bca)
- [1345ae95eed0e4cdc920757483e1e53985d9777c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1345ae95eed0e4cdc920757483e1e53985d9777c)
- [1d8b5fb919e8383ca1d125f3dc25e780179bfa82](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d8b5fb919e8383ca1d125f3dc25e780179bfa82)
- [db0c34d63c95780d4cbf8a2673a4ebda5b138f17](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/db0c34d63c95780d4cbf8a2673a4ebda5b138f17)
- [3b2bec346f34535ce527f239be43b532e525625c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3b2bec346f34535ce527f239be43b532e525625c)
- [e5232655ca4ba95eaa40e143ad1c6444240a2045](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e5232655ca4ba95eaa40e143ad1c6444240a2045)

## Adds Configurations for Sending Emails

Restructures mailer abstractions and adds configurations to allow disabling all emails in unit tests and optionally disabling “transactional” emails when an email service provider is integrated with the application.

- Adds `Workarea::ApplicationMailer` in Core, which encapsulates all shared logic for Workarea mailers
- Updates `Admin::ApplicationMailer` and `Storefront::ApplicationMailer` to inherit from `Workarea::ApplicationMailer`
- Adds `Workarea.config.send_email`, which defaults to `true`
- Adds setup to `Workarea::TestCase` to disable emails in unit tests (sets `send_email` to `false`)
- Adds module `Workarea::TestCase::Mail`, which can be mixed into any test case that should send mail
- Includes `Workarea::TestCase::Mail` in `Workarea::IntegrationTest` and `Workarea::SystemTest` to enable emails by default in integration and system tests
- Adds module `Workarea::Storefront::TransactionalMailer`, which is mixed into mailers that are considered “transactional” and are often replaced with emails from an integrated ESP
- Adds `Workarea.config.send_transactional_emails`, which defaults to `true`, but can be used to disable sending of transactional emails if desired

### Issues

- [ECOMMERCE-5200](https://jira.tools.weblinc.com/browse/ECOMMERCE-5200)
- [ECOMMERCE-5633](https://jira.tools.weblinc.com/browse/ECOMMERCE-5633)

### Pull Requests

- [2785](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2785/overview)
- [3066](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3066/overview)

### Commits

- [ea502325b5712844f69b098a8b9a841c059a1098](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ea502325b5712844f69b098a8b9a841c059a1098)
- [8b41209a831e88d7c6053d193abdb654570ada00](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8b41209a831e88d7c6053d193abdb654570ada00)
- [0c83b04832b73b275b9238b545fb7108f13270c0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0c83b04832b73b275b9238b545fb7108f13270c0)
- [c81a85befd6bd41a3aeb060e63ebc18ef25a57f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c81a85befd6bd41a3aeb060e63ebc18ef25a57f4)

## Adds Taxonomy-Based Slug Generation to Creation Workflows

Generates unique taxonomy-based slugs for categories and content pages created through the corresponding workflows in the Admin.

For example, an administrator uses the “create page” Admin workflow to create a content page named “Locations”, and (during the workflow) places the page under the page “About Us” in the site's taxonomy. The slug stored on the new page will be `'about-us-locations'`, reflecting the page's position in the taxonomy.

Furthermore, the feature removes from those workflows the field to manually set a slug.

### Issues

- [ECOMMERCE-5199](https://jira.tools.weblinc.com/browse/ECOMMERCE-5199)

### Pull Requests

- [2778](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2778/overview)
- [2794](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2794/overview)

### Commits

- [413715f33b1ec6b2631a3d26660bc109d518648f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/413715f33b1ec6b2631a3d26660bc109d518648f)
- [e068bfffc13d3443160522ef6bf54d3fa6a582d7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e068bfffc13d3443160522ef6bf54d3fa6a582d7)
- [3d6bc31c2575398d5259a55bac29e1ea02fa5d90](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3d6bc31c2575398d5259a55bac29e1ea02fa5d90)
- [98bce11b50b9006b619aa53cfdfc2c64f140785a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/98bce11b50b9006b619aa53cfdfc2c64f140785a)

## Improves Mobile Filters UI in Storefront

Changes the mobile filters UI in the Storefront to a “drawer” to be consistent with the mobile navigation.

- Deprecates the `.mobile-filters` component.
- Adds the `.mobile-filters-nav` component.
- Adds `WORKAREA.mobileFilterButtons`, which duplicates the existing module, `WORKAREA.mobileNavButton`. These are planned to be consolidated in Workarea 4.

### Issues

- [ECOMMERCE-5588](https://jira.tools.weblinc.com/browse/ECOMMERCE-5588)

### Pull Requests

- [3076](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3076/overview)

### Commits

- [324eaf26e36accf5b857aa7e8c2feef1a1a2b427](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/324eaf26e36accf5b857aa7e8c2feef1a1a2b427)
- [68b1f90d8b5260be616edc5754d4ad78cc1b5c6d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/68b1f90d8b5260be616edc5754d4ad78cc1b5c6d)
- [8b2aea2896131378e1f1723345d011e387f23c67](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8b2aea2896131378e1f1723345d011e387f23c67)

## Adds Email Unsubscribing in the Storefront

Adds support for unsubscribing to email in the Storefront account area. This change helps retailers comply with the [GDPR](https://www.eugdpr.org/).

### Issues

- [ECOMMERCE-5606](https://jira.tools.weblinc.com/browse/ECOMMERCE-5606)

### Pull Requests

- [3088](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3088/overview)

### Commits

- [e51463cd517a2704564c916dc27c04b68a5c10fc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e51463cd517a2704564c916dc27c04b68a5c10fc)
- [3d91c2e7e48b1b979edbb16c159940e3893e9c01](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3d91c2e7e48b1b979edbb16c159940e3893e9c01)

## Adds Storefront “Back to Top” Buttons

Adds “Back to Top” functionality to categories show and searches show in the Storefront.

### Issues

- [ECOMMERCE-5497](https://jira.tools.weblinc.com/browse/ECOMMERCE-5497)

### Pull Requests

- [2975](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2975/overview)

### Commits

- [32e0e6dd8597199cbb0155be101ba50a894eb91a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32e0e6dd8597199cbb0155be101ba50a894eb91a)
- [28e63e0c7f4709952c2ae3b8a1d74a987276e4b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/28e63e0c7f4709952c2ae3b8a1d74a987276e4b5)

## Adds Rack Attack Protection for Promo Codes & User Accounts

Adds Rack Attack protection for promo code endpoints to prevent brute forcing of promo codes, and user account creation endpoints to prevent leaking email addresses.

### Issues

- [ECOMMERCE-5307](https://jira.tools.weblinc.com/browse/ECOMMERCE-5307)
- [ECOMMERCE-5641](https://jira.tools.weblinc.com/browse/ECOMMERCE-5641)

### Pull Requests

- [2845](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2845/overview)
- [3073](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3073/overview)

### Commits

- [08c52796913691d49e91f11bffcb0c8e3b37a89a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08c52796913691d49e91f11bffcb0c8e3b37a89a)
- [80b85453ee245f2ae81a6468db07ed73dd7d482a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/80b85453ee245f2ae81a6468db07ed73dd7d482a)
- [4cb20adab9425237a64292420d4c24b4d70f160c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4cb20adab9425237a64292420d4c24b4d70f160c)
- [1d763146f89da22102e4769851f75088c82f02b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1d763146f89da22102e4769851f75088c82f02b0)

## Improves Performance of Promo Code List Generation

Implements a unique index, allowing the removal of n+1 queries to check if a code exists.

### Issues

- [ECOMMERCE-5390](https://jira.tools.weblinc.com/browse/ECOMMERCE-5390)

### Pull Requests

- [2909](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2909/overview)

### Commits

- [f5afc98c588933fc3e8a97079d50aea3f17720c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f5afc98c588933fc3e8a97079d50aea3f17720c6)
- [f015edd945c4b794eb40971bff37813c57b74f39](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f015edd945c4b794eb40971bff37813c57b74f39)

## Moves Order Locking to Redis

Moves order locking persistence to Redis (from MongoDB) to improve performance.

- Adds Core model `Lock`
- Adds Core model mixin `Lockable`
- Modifies Core model `Order`
- Modifies Storefront controller `CheckoutsController`
- Adds config `Workarea.config.default_lock_expiration`
- Deprecates config `Workarea.config.order_lock_period`

### Issues

- [ECOMMERCE-5361](https://jira.tools.weblinc.com/browse/ECOMMERCE-5361)

### Pull Requests

- [2887](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2887/overview)

### Commits

- [b2d6514f17d3f24fdb406ec4a45322ad79d1cd52](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b2d6514f17d3f24fdb406ec4a45322ad79d1cd52)
- [d5ea0727dd461135eb31a7151cc34e0f56270ef3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5ea0727dd461135eb31a7151cc34e0f56270ef3)

## Improves Performance of Processing Product Recommendations

Modifies the workers that process product recommendations, increasing the number of documents loaded per query. Also makes these values configurable.

### Issues

- [ECOMMERCE-5642](https://jira.tools.weblinc.com/browse/ECOMMERCE-5642)

### Pull Requests

- [3075](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3075/overview)

### Commits

- [2e51a235426b7d616839e67dc6c988f4b0d3abb2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e51a235426b7d616839e67dc6c988f4b0d3abb2)
- [6cce2861b080defa4ff4bffa7a871882067d419f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6cce2861b080defa4ff4bffa7a871882067d419f)

## Adds Performance Tests

Adds performance tests, which measure the performance of particular platform features and fail when performance drops beyond a given threshold after changes are made. These tests, currently for use by the base platform only, can identify platform changes that negatively impact performance (so they can be rolled back or improved). A future release of the platform will provide this feature for use by applications.

### Issues

- [ECOMMERCE-5414](https://jira.tools.weblinc.com/browse/ECOMMERCE-5414)
- [ECOMMERCE-5589](https://jira.tools.weblinc.com/browse/ECOMMERCE-5589)

### Pull Requests

- [2934](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2934/overview)
- [3031](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3031/overview)
- [3087](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3087/overview)

### Commits

- [6717394f18caee47c1952dcebe7b3456bb10b2d5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6717394f18caee47c1952dcebe7b3456bb10b2d5)
- [c4becbad175f835f99f5d7a0960a00f2e80549d4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c4becbad175f835f99f5d7a0960a00f2e80549d4)
- [248e5843f4d0633bdb979384397d5be218f07b61](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/248e5843f4d0633bdb979384397d5be218f07b61)
- [2261c45b65496ebb96ddee61c70eb86633469103](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2261c45b65496ebb96ddee61c70eb86633469103)
- [b3b06667e2a1ff5bdfb125828d093f0e9637c809](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3b06667e2a1ff5bdfb125828d093f0e9637c809)
- [882de0228341e4c107c1e2ffe9cae2a018c4b453](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/882de0228341e4c107c1e2ffe9cae2a018c4b453)

## Adds Support for Returns & OMS Features

Applies various improvements to support the Returns and OMS plugins.

- Modifies Core model `Payment::Capture`
- Modifies Core model `Payment::Processing`
- Modifies Core model `Payment::Refund`
- Modifies Core model `Payment::Tender`
- Modifies Core model `Payment::Transaction`
- Modifies Core model `BulkAction`
- Adds Storefront controller mixin `OrderLookup`
- Modifies Storefront controller `OrdersController`
- Modifies Storefront routes
- Adds append points to Storefront
- Adds library `BogusCarrier` (Active Shipping carrier) for testing
- Extends external library `GlobalID` to add Mongoid support

### Issues

- [ECOMMERCE-5407](https://jira.tools.weblinc.com/browse/ECOMMERCE-5407)
- [ECOMMERCE-5408](https://jira.tools.weblinc.com/browse/ECOMMERCE-5408)
- [ECOMMERCE-5200](https://jira.tools.weblinc.com/browse/ECOMMERCE-5200)
- [ECOMMERCE-5409](https://jira.tools.weblinc.com/browse/ECOMMERCE-5409)
- [ECOMMERCE-5410](https://jira.tools.weblinc.com/browse/ECOMMERCE-5410)
- [ECOMMERCE-5546](https://jira.tools.weblinc.com/browse/ECOMMERCE-5546)

### Pull Requests

- [2908](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2908/overview)
- [2966](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2966/overview)
- [3016](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3016/overview)
- [2944](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2944/overview)

### Commits

- [9cf41a07b2c90eaef3b5bbdc09c2a2ad7de354de](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9cf41a07b2c90eaef3b5bbdc09c2a2ad7de354de)
- [f528df9d7f2d6da747b254c7b5dafcb79690d1bc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f528df9d7f2d6da747b254c7b5dafcb79690d1bc)
- [30f60c763529ff452bb00e8ebf519c053934352a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/30f60c763529ff452bb00e8ebf519c053934352a)
- [4ec8efe5f77d6dbe1fcf4a168a2f97b493c8dc84](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4ec8efe5f77d6dbe1fcf4a168a2f97b493c8dc84)
- [dd88d11364e8570182704b83505b3d5b3136e903](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd88d11364e8570182704b83505b3d5b3136e903)
- [03519660062ac023e04c3d7fac5621606a07d40c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/03519660062ac023e04c3d7fac5621606a07d40c)
- [e8b8eb8e74da51a96419ffd3836ec1341651e273](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e8b8eb8e74da51a96419ffd3836ec1341651e273)
- [1e5342528125f7dd0260d17698f077f9c9d406b1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e5342528125f7dd0260d17698f077f9c9d406b1)
- [3e89e881221a50876847a53d12d3c60a86ac9231](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3e89e881221a50876847a53d12d3c60a86ac9231)
- [f540f11dca670a5edd49cdf527dc7635c9694181](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f540f11dca670a5edd49cdf527dc7635c9694181)
- [fb6575edcb089c547a58921a1a1fedaeb96f522d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fb6575edcb089c547a58921a1a1fedaeb96f522d)
- [e216e26ca758047918fd4e8b82fb0d1f85e59572](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e216e26ca758047918fd4e8b82fb0d1f85e59572)
- [348a9db2c8a80e8a763b8f297dd2fe92bbb954d2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/348a9db2c8a80e8a763b8f297dd2fe92bbb954d2)
- [97d7d715eb36aaa07b219ef33f2faa00cc23d95a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/97d7d715eb36aaa07b219ef33f2faa00cc23d95a)

## Adds Inventory Restocking

Adds Core APIs within the `Inventory` module to allow restocking of inventory. This change is added primarily to support the OMS plugin.

### Issues

- [ECOMMERCE-5249](https://jira.tools.weblinc.com/browse/ECOMMERCE-5249)

### Pull Requests

- [2806](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2806/overview)

### Commits

- [5e6518bf083414b8e18f4f54e3f61bfc8493acc6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5e6518bf083414b8e18f4f54e3f61bfc8493acc6)
- [f42dbb9dae33c719df0175f1f488e5868da73a0e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f42dbb9dae33c719df0175f1f488e5868da73a0e)

## Adds Low Inventory Alerts in Admin

Improves visibility of low inventory in Admin.

- Adds alert to Admin and Admin toolbar
- Adds section to Admin status report email
- Adds sort to inventory skus

### Issues

- [ECOMMERCE-5450](https://jira.tools.weblinc.com/browse/ECOMMERCE-5450)
- [ECOMMERCE-5442](https://jira.tools.weblinc.com/browse/ECOMMERCE-5442)
- [ECOMMERCE-5536](https://jira.tools.weblinc.com/browse/ECOMMERCE-5536)

### Pull Requests

- [2935](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2935/overview)
- [3004](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3004/overview)

### Commits

- [b4cb46f5d6fe05b6503ae863fbfb9b0628bb2779](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b4cb46f5d6fe05b6503ae863fbfb9b0628bb2779)
- [c9736ad9e98ee3076e8e8369eed14c82185bcd6c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c9736ad9e98ee3076e8e8369eed14c82185bcd6c)
- [be96ba0cefbbdb2f1d4d0fb4422fa18a93223212](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be96ba0cefbbdb2f1d4d0fb4422fa18a93223212)
- [331c55e869a9b5dd8296c348729febbbcc115a16](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/331c55e869a9b5dd8296c348729febbbcc115a16)

## Adds Payment Status for Orders Without Tenders

Adds a `NotApplicable` `Payment::Status` for use with orders that do not require tenders.

### Issues

- [ECOMMERCE-5222](https://jira.tools.weblinc.com/browse/ECOMMERCE-5222)

### Pull Requests

- [2788](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2788/overview)

### Commits

- [27f0fc58679cb6127e059233c76f31f6b68361c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/27f0fc58679cb6127e059233c76f31f6b68361c6)
- [aff0b335a21115df0ab675b1f29d74ef886a83e0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aff0b335a21115df0ab675b1f29d74ef886a83e0)

## Removes Deprecated Storefront Search Auto Filter Middleware

Removes from Workarea Core the file _app/queries/workarea/search/storefront\_search/auto\_filter.rb_, which defines `Workarea::Search::StorefrontSearch::AutoFilter`. This search middleware was deprecated in Workarea 3.1.

### Pull Requests

- [3043](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3043/overview)

### Commits

- [f66088711a905a91ff1f7b5ef3723ccaf4bc9ffa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f66088711a905a91ff1f7b5ef3723ccaf4bc9ffa)
- [7475855f31daa6746fefc6fb64999aed2f69796f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7475855f31daa6746fefc6fb64999aed2f69796f)

## Removes Deprecated Order-Fulfillment Status

Removes `OrderFulfillmentStatus` and similar logic within `Admin::OrderViewModel`, since the concept of combined order-fulfillment status was removed in Workarea 3.1.

### Pull Requests

- [3042](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3042/overview)
- [3043](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3043/overview)

### Commits

- [db1a9da4bd71fa536c46d8cf4609f4c8ab059256](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/db1a9da4bd71fa536c46d8cf4609f4c8ab059256)
- [8a5c5a449ff56731144dca629d05eba1ad174dbb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8a5c5a449ff56731144dca629d05eba1ad174dbb)
- [f66088711a905a91ff1f7b5ef3723ccaf4bc9ffa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f66088711a905a91ff1f7b5ef3723ccaf4bc9ffa)
- [7475855f31daa6746fefc6fb64999aed2f69796f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7475855f31daa6746fefc6fb64999aed2f69796f)

## Improves Admin to Support Fulfillment Dashboard

Adds append points, sorts, and configuration to support the order fulfillment dashboard in the OMS plugin.

### Issues

- [ECOMMERCE-5585](https://jira.tools.weblinc.com/browse/ECOMMERCE-5585)

### Pull Requests

- [3023](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3023/overview)
- [3030](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3030/overview)

### Commits

- [52be2b36f42e8c257cf51b9dc4b48e84d550c558](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/52be2b36f42e8c257cf51b9dc4b48e84d550c558)
- [5f44b81b8576624815bc0b541dfa26965ffdde7d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5f44b81b8576624815bc0b541dfa26965ffdde7d)
- [01982148b8fbd003e6ed282458a0abc6ab9ddafa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/01982148b8fbd003e6ed282458a0abc6ab9ddafa)
- [e1bd2a82f8f0bd7c93386e4a472d5b42596e2a16](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e1bd2a82f8f0bd7c93386e4a472d5b42596e2a16)

## Ensures Jobs to Publish & Undo Releases aren't Dropped

Adds the worker `Workarea::VerifyScheduledReleases`, which runs on a schedule and inspects the Sidekiq queue to ensure all jobs for publishing and undoing releases are present. If any are found missing, the worker adds the missing jobs to the queue.

### Issues

- [ECOMMERCE-5419](https://jira.tools.weblinc.com/browse/ECOMMERCE-5419)

### Pull Requests

- [2917](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2917/overview)

### Commits

- [5129befd9e76e22ffbb4ce6280ded72d488be9dc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5129befd9e76e22ffbb4ce6280ded72d488be9dc)
- [e285ebceb9d28bc342189e0dbc1af27f4b2bd931](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e285ebceb9d28bc342189e0dbc1af27f4b2bd931)

## Ensures Saved Credit Cards are Stored on the Gateway

Modifies the Core payment models `SavedCreditCard` and `StoreCreditCard` to ensure saved credit cards are stored on the gateway.

### Issues

- [ECOMMERCE-5339](https://jira.tools.weblinc.com/browse/ECOMMERCE-5339)

### Pull Requests

- [2866](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2866/overview)

### Commits

- [65ffc7a02fc3c3387a54e72182b0829d315cf45b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/65ffc7a02fc3c3387a54e72182b0829d315cf45b)
- [2e1947d80dc268a682389ca0ce08ea5bbd4f3b51](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e1947d80dc268a682389ca0ce08ea5bbd4f3b51)
- [7a549679620827ad1944ad74903e25d3c4609400](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7a549679620827ad1944ad74903e25d3c4609400)

## Adds Logic for Saving a Credit Card as the Default Card

Modifies the `SaveUserOrderDetails` worker to set the credit card being saved as the default credit card if there are no existing cards saved on the payment profile. The increases the likelihood a user has a default card, which is particularly useful for subscriptions.

### Issues

- [ECOMMERCE-5393](https://jira.tools.weblinc.com/browse/ECOMMERCE-5393)

### Pull Requests

- [2903](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2903/overview)

### Commits

- [afc91de2583e7ad22a0d790e64b7caef624b31b1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/afc91de2583e7ad22a0d790e64b7caef624b31b1)
- [4439b0770b1e04054a7ab324813ded7db40dee41](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4439b0770b1e04054a7ab324813ded7db40dee41)

## Improves Style Guides

Improves navigation and overall presentation of Admin and Storefront style guides.

### Issues

- [ECOMMERCE-4603](https://jira.tools.weblinc.com/browse/ECOMMERCE-4603)
- [ECOMMERCE-5474](https://jira.tools.weblinc.com/browse/ECOMMERCE-5474)
- [ECOMMERCE-5600](https://jira.tools.weblinc.com/browse/ECOMMERCE-5600)

### Pull Requests

- [2929](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2929/overview)
- [3024](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3024/overview)
- [3039](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3039/overview)

### Commits

- [dcb342e07fca86895fb4503a613c702cc65ff29a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dcb342e07fca86895fb4503a613c702cc65ff29a)
- [2c0d585d9572eaf1442c1363afde7a267ba0bc80](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c0d585d9572eaf1442c1363afde7a267ba0bc80)
- [bbf21dcbabfef91f147595ddbadcbdedbf49ce49](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bbf21dcbabfef91f147595ddbadcbdedbf49ce49)
- [19a43ddc9c2cb0dc94098ffc3e67c056a7d4d5d6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/19a43ddc9c2cb0dc94098ffc3e67c056a7d4d5d6)
- [381a9aa13c967fd6bd9211fd4cd48f9da96fb70c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/381a9aa13c967fd6bd9211fd4cd48f9da96fb70c)
- [b792395a7560804e64b583ea4a8f55dbdfc796de](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b792395a7560804e64b583ea4a8f55dbdfc796de)
- [bf485be5f05909ca4d651de1591447f5cc765c1b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bf485be5f05909ca4d651de1591447f5cc765c1b)
- [e53f959abbae40d127da9a7b1992d7060a7eb44c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e53f959abbae40d127da9a7b1992d7060a7eb44c)

## Improves Closing of Storefront Mobile Navigation

Modifies the Storefront mobile navigation to close when a user clicks outside the component.

### Issues

- [ECOMMERCE-5587](https://jira.tools.weblinc.com/browse/ECOMMERCE-5587)

### Pull Requests

- [3063](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3063/overview)

### Commits

- [4d86aa0455076afc6560978661e2aca5a84d8935](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4d86aa0455076afc6560978661e2aca5a84d8935)
- [8c547867cf99223526f09c72f288de7cbceb5d80](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8c547867cf99223526f09c72f288de7cbceb5d80)
- [82eb1c8252afc756715c8f424760bd6481b9011d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/82eb1c8252afc756715c8f424760bd6481b9011d)
- [67eddf43e8a31d359de682f16e44540189730e37](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/67eddf43e8a31d359de682f16e44540189730e37)

## Adds Fieldset Renaming to Content Block DSL

Adds to the content block DSL the ability to change the name of a fieldset within an existing block type.

### Issues

- [ECOMMERCE-5624](https://jira.tools.weblinc.com/browse/ECOMMERCE-5624)

### Pull Requests

- [3067](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3067/overview)

### Commits

- [7ef9898e1aa66db54a604ba5f2be147b14ae4c46](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7ef9898e1aa66db54a604ba5f2be147b14ae4c46)
- [295e8343f39f210cbd906f4dca345e0ce46119e0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/295e8343f39f210cbd906f4dca345e0ce46119e0)

## Fixes Rails Generators for Plugins

Modifies the plugin template to fix Rails generators for new plugins. Existing plugins can apply this change manually to fix generators if desired.

### Issues

- [ECOMMERCE-5343](https://jira.tools.weblinc.com/browse/ECOMMERCE-5343)

### Pull Requests

- [3069](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3069/overview)

### Commits

- [d0a073b59672eb5a0d121da8e006d92f2d5f73e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d0a073b59672eb5a0d121da8e006d92f2d5f73e6)
- [cf7fa520242abf0fd8c004cdd78bac7b8c601f29](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cf7fa520242abf0fd8c004cdd78bac7b8c601f29)

## Improves Performance & Security of Pages with External Links

Adds a `rel="noopener"` attribute to all links that open in a new window. This is a [recommendation from Google](https://developers.google.com/web/tools/lighthouse/audits/noopener) that improves performance and security.

### Issues

- [ECOMMERCE-5116](https://jira.tools.weblinc.com/browse/ECOMMERCE-5116)

### Pull Requests

- [2808](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2808/overview)

### Commits

- [4cd4782e8d4910c28b61f196dfbf8dbc46234239](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4cd4782e8d4910c28b61f196dfbf8dbc46234239)
- [f9935ab15a301ffaf6dce1546c615e2b23549e9c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f9935ab15a301ffaf6dce1546c615e2b23549e9c)

## Adds Tracking & Display of Order “Source”

Adds a field on `Order` to save the “source” of a placed order. For example, the Storefront checkout sets the value to `'admin'` when the current user is an administrator, or `'storefront'` otherwise. The Admin displays this value for each order. Other user interfaces may set this field to other values as relevant.

### Issues

- [ECOMMERCE-5198](https://jira.tools.weblinc.com/browse/ECOMMERCE-5198)

### Pull Requests

- [2775](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2775/overview)

### Commits

- [d872a2d62c0d12fcafde7a2494962fc7b7286af6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d872a2d62c0d12fcafde7a2494962fc7b7286af6)
- [57bbe3188875c22be57654a36cf4a72aede339b4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/57bbe3188875c22be57654a36cf4a72aede339b4)

## Adds Async Release Creation

Allows administrators to create a new release asynchronously when choosing which release to publish changes with.

- Modifies `WORKAREA.publishWithReleaseMenus` JavaScript module
- Adds `.property--no-margin` component modifier

### Issues

- [ECOMMERCE-5202](https://jira.tools.weblinc.com/browse/ECOMMERCE-5202)

### Pull Requests

- [2833](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2833/overview)
- [2846](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2846/overview)
- [2865](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2865/overview)

### Commits

- [0e7123f34889b765b6c57f923cb54ebe9c8730bd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0e7123f34889b765b6c57f923cb54ebe9c8730bd)
- [eb39f48c442ee429cd83e580c8f4fc7b170bfe34](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb39f48c442ee429cd83e580c8f4fc7b170bfe34)
- [30e7b019eb10eca95c3b3abefa97b6a1776adb8d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/30e7b019eb10eca95c3b3abefa97b6a1776adb8d)
- [167d1ebdaaef202f46e378ef3d54197c980c2afa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/167d1ebdaaef202f46e378ef3d54197c980c2afa)
- [b2a32366c46f61c4ca79bd14401704ea06a6ba12](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b2a32366c46f61c4ca79bd14401704ea06a6ba12)
- [dcb87474f6c9161d822a6b6c8cc89df037ce2041](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dcb87474f6c9161d822a6b6c8cc89df037ce2041)
- [4686139a9770de00eb4eb9cb988da64b77a3f98b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4686139a9770de00eb4eb9cb988da64b77a3f98b)

## Adds Administration of Product Default Category

Allows administrators to set the default category for each product manually. Also displays the default category for each product in the Admin.

- Adds `default_category_id` field to `Catalog::Product`
- Modifies the `Workarea::Categorization` query to use the above field when present
- Modifies `Admin::ProductViewModel` to present the default category within the Admin

### Issues

- [ECOMMERCE-5360](https://jira.tools.weblinc.com/browse/ECOMMERCE-5360)

### Pull Requests

- [2878](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2878/overview)
- [2921](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2921/overview)

### Commits

- [462688f0e6f8323868863fb0d7b0a6793b7d0195](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/462688f0e6f8323868863fb0d7b0a6793b7d0195)
- [5f1b06f2e6bd77de337fd0bd4c488f4f0a07e0ef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5f1b06f2e6bd77de337fd0bd4c488f4f0a07e0ef)
- [dc9c6ffa07841305a2576159805e57aa575b24c1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dc9c6ffa07841305a2576159805e57aa575b24c1)
- [1febee7412ad273d8f40a7799807c6b53b3a004b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1febee7412ad273d8f40a7799807c6b53b3a004b)

## Enforces Unique DOM IDs in the Admin

Adds a JavaScript module to enforce unique DOM IDs in the Admin in Test and Development environments. This change was applied to the Storefront in Workarea 3.1.

If this change is burdensome for your application, remove the following line from your Admin JavaScript manifest:

```
require_asset 'workarea/core/modules/duplicate_id'
```

### Issues

- [ECOMMERCE-5347](https://jira.tools.weblinc.com/browse/ECOMMERCE-5347)

### Pull Requests

- [2890](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2890/overview)

### Commits

- [4c528f4346b1cc8eaf2c8f8c93d914332005608b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c528f4346b1cc8eaf2c8f8c93d914332005608b)
- [f054823920fea5775eae6545c46d46762ad966b8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f054823920fea5775eae6545c46d46762ad966b8)

## Adds Admin User Impersonation Indicator

Modifies Admin header to indicate when an administrator is impersonating another user.

### Issues

- [ECOMMERCE-5436](https://jira.tools.weblinc.com/browse/ECOMMERCE-5436)

### Pull Requests

- [2951](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2951/overview)

### Commits

- [62ed27914d73ed9fd5faa24eb5b0edc46b71cb94](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/62ed27914d73ed9fd5faa24eb5b0edc46b71cb94)
- [32811c7b33500470664bc1ba085ea948f3e01ec0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32811c7b33500470664bc1ba085ea948f3e01ec0)

## Adds Convenience Methods to Remove Appends

Adds the following methods to the `Workarea::Plugin` module for removing appends within your application or plugin configuration code. These methods mirror the existing methods for adding appends.

- `remove_stylesheets`
- `remove_javascripts`
- `remove_partials`

### Issues

- [ECOMMERCE-5094](https://jira.tools.weblinc.com/browse/ECOMMERCE-5094)

### Pull Requests

- [2942](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2942/overview)

### Commits

- [ff54ae3c39a4950b16e12335a9a7285e50224f0b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff54ae3c39a4950b16e12335a9a7285e50224f0b)
- [be0b38021e1ec67d8b2013cf65987851a9d21c0d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be0b38021e1ec67d8b2013cf65987851a9d21c0d)
- [89cbf662063764ed33da748ce8e80346e72e7829](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/89cbf662063764ed33da748ce8e80346e72e7829)

## Extracts Changelog Task to Core Library

Extracts the changelog Rake task to the Core library so it can be used by plugins and does not need to be duplicated.

### Issues

- [ECOMMERCE-5354](https://jira.tools.weblinc.com/browse/ECOMMERCE-5354)

### Pull Requests

- [2904](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2904/overview)

### Commits

- [83674d520fa7a3d0656deff93a106e81c4c6a480](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/83674d520fa7a3d0656deff93a106e81c4c6a480)
- [383858a0ae39096ac66d7b7e85413728c4843ece](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/383858a0ae39096ac66d7b7e85413728c4843ece)
- [49b5a209232b04ac0c2c001169fdd62dcab9acc7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/49b5a209232b04ac0c2c001169fdd62dcab9acc7)

## Adds Per-Plugin Test Runners

Adds an additional test runner for each installed plugin, enabling developers to easily run the tests from a particular plugin (including decorators in the application).

### Issues

- [ECOMMERCE-5470](https://jira.tools.weblinc.com/browse/ECOMMERCE-5470)

### Pull Requests

- [2943](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2943/overview)
- [2948](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2948/overview)

### Commits

- [23ae328fda7774f29ff639045e8ee9fa5bcde387](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/23ae328fda7774f29ff639045e8ee9fa5bcde387)
- [005534725bb4c4675af2b1c8abebad2cf839fe65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/005534725bb4c4675af2b1c8abebad2cf839fe65)
- [05f269f80d2e1a657fab556bf0ab4fc7d2f2931e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/05f269f80d2e1a657fab556bf0ab4fc7d2f2931e)
- [14148a04e922c3731f78c9a8af7aa20ef30de827](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/14148a04e922c3731f78c9a8af7aa20ef30de827)
- [b7dd440a6e2e267fb9796574d3e16edbc3edc6ef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7dd440a6e2e267fb9796574d3e16edbc3edc6ef)

## Updates Statuses within Order Seeds

Updates orders seeds to capture and ship some of the items to provide a greater variety of statuses in the Admin.

### Issues

- [ECOMMERCE-5493](https://jira.tools.weblinc.com/browse/ECOMMERCE-5493)

### Pull Requests

- [2970](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2970/overview)
- [3015](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3015/overview)

### Commits

- [f9fe9c63d2d89edfa42439d7bfeff12dfb213b4f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f9fe9c63d2d89edfa42439d7bfeff12dfb213b4f)
- [c827047a6aea85c192d5399a236cf817b82b271b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c827047a6aea85c192d5399a236cf817b82b271b)
- [cc9139261530bc33aa30ea7a040a76099a6bd9a7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cc9139261530bc33aa30ea7a040a76099a6bd9a7)
- [3ad38f9102481d95fe808c1a51df5c3d3621eed6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3ad38f9102481d95fe808c1a51df5c3d3621eed6)

## Adds Seed for “Internal Server Error”

Seeds a system content named “Internal Server Error” within _core/app/seeds/workarea/customer\_service\_pages\_seeds.rb_. This page will be used when responding with a 500 error.

### Issues

- [ECOMMERCE-5519](https://jira.tools.weblinc.com/browse/ECOMMERCE-5519)

### Pull Requests

- [2985](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2985/overview)

### Commits

- [0557b02d71384af44d1c5eed1239db59b42e31c4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0557b02d71384af44d1c5eed1239db59b42e31c4)
- [a2fac8c499ce6c8c64ee9d747a717b2d599c0326](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a2fac8c499ce6c8c64ee9d747a717b2d599c0326)

## Fixes `create_placed_order` Factory Failing Silently

Raises an exception when the `create_placed_order` factory fails to place the order. This change was requested to aid debugging.

### Issues

- [ECOMMERCE-5308](https://jira.tools.weblinc.com/browse/ECOMMERCE-5308)

### Pull Requests

- [2843](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2843/overview)

### Commits

- [a35a8404c020d4aa171a5977959e4ea874d1b760](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a35a8404c020d4aa171a5977959e4ea874d1b760)
- [3fe9ab9dd27dd6c9fdda89935cf6d6421ba90cda](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3fe9ab9dd27dd6c9fdda89935cf6d6421ba90cda)

## Adds Configuration & Setup for Headless Browser Window Size

Adds setup to system tests that resets the headless browser width and height to configured values. This ensures a consistent starting size for all system tests. Adds `Workarea.config.capybara_browser_width` and `Workarea.config.capybara_browser_height` to configure these values.

### Commits

- [3149cbb5844ec39ccb3c10854dc51ed969f80fe8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3149cbb5844ec39ccb3c10854dc51ed969f80fe8)

## Improves Dialog Module to Allow Chaining

Updates `WORKAREA.dialog.create()` within the Storefront to return the jQuery collection representing the dialog. This change allows chaining.

### Issues

- [ECOMMERCE-5247](https://jira.tools.weblinc.com/browse/ECOMMERCE-5247)

### Pull Requests

- [2823](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2823/overview)

### Commits

- [8e1e5b902c81d2d730f085cb6b1e0503bfe8f431](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8e1e5b902c81d2d730f085cb6b1e0503bfe8f431)
- [ae93492de8612e9a7de8c00b45eb39d077bb7889](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ae93492de8612e9a7de8c00b45eb39d077bb7889)

## Adds Payment Processing Model Index

Adds a MongoDB index for the payment on payment processing models. This change supports queries performed in plugins.

### Issues

- [OMS-80](https://jira.tools.weblinc.com/browse/OMS-80)

### Commits

- [5c8d9e4330287e8995b109c3dbc0124e01b54144](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5c8d9e4330287e8995b109c3dbc0124e01b54144)

## Adds Client-Side Validation of Phone Number Format

Adds client-side validation to the phone number field within Storefront address forms to ensure only digits and dashes are used.

### Issues

- [ECOMMERCE-4965](https://jira.tools.weblinc.com/browse/ECOMMERCE-4965)

### Pull Requests

- [3049](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3049/overview)

### Commits

- [11c068f0255b4d9e89b280ba5dbf545021683b2a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/11c068f0255b4d9e89b280ba5dbf545021683b2a)
- [1a8aa0c8a946b2dbf8e28a2af834f529ddc6b64e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a8aa0c8a946b2dbf8e28a2af834f529ddc6b64e)
- [6dbc2e13f7c5611ad9354749ea341f41c1e83f68](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6dbc2e13f7c5611ad9354749ea341f41c1e83f68)

## Adds Email to Order Confirmation

Updates the Storefront order confirmation page to notify the customer a confirmation email was sent to their email address. This reassures customers and helps resolve issues with email typos.

### Issues

- [ECOMMERCE-5042](https://jira.tools.weblinc.com/browse/ECOMMERCE-5042)

### Pull Requests

- [3048](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3048/overview)

### Commits

- [f47a4dcf6df86ea244158b2030fdc2938a46a99a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f47a4dcf6df86ea244158b2030fdc2938a46a99a)
- [39848fab50667c54ba83954550ee547c8d877fea](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/39848fab50667c54ba83954550ee547c8d877fea)

## Improves “Disabled” State of Form Controls

Improves the default styling of the “disabled” state for form controls within the Admin and Storefront.

### Issues

- [ECOMMERCE-5255](https://jira.tools.weblinc.com/browse/ECOMMERCE-5255)
- [ECOMMERCE-5621](https://jira.tools.weblinc.com/browse/ECOMMERCE-5621)
- [ECOMMERCE-5636](https://jira.tools.weblinc.com/browse/ECOMMERCE-5636)

### Pull Requests

- [3050](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3050/overview)
- [3058](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3058/overview)

### Commits

- [ba20c30fabc085b184a0415fd5b40cb8407903c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ba20c30fabc085b184a0415fd5b40cb8407903c6)
- [4f4344eaf83da952ef1ec04f5fc6db45db067b55](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4f4344eaf83da952ef1ec04f5fc6db45db067b55)
- [39a4e4a3e2c1c5e52771de462a0c8c2809b6af93](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/39a4e4a3e2c1c5e52771de462a0c8c2809b6af93)
- [1b5dfe1b981855535a585e611220d00220ab0a1c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1b5dfe1b981855535a585e611220d00220ab0a1c)
- [4a0ab2a93be83ba8499c051a252e0cb259771e85](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4a0ab2a93be83ba8499c051a252e0cb259771e85)

## Improves Payment Icons to Allow Issuer-Specific Styling

Adds modifiers for card issuers to the _payment-icon_ components in the Admin and Storefront. This change allows targeting and styling the icon of a particular card issuer.

### Issues

- [ECOMMERCE-5406](https://jira.tools.weblinc.com/browse/ECOMMERCE-5406)
- [ECOMMERCE-5406](https://jira.tools.weblinc.com/browse/ECOMMERCE-5406)

### Pull Requests

- [2905](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2905/overview)
- [2910](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2910/overview)

### Commits

- [d4afcaad71c13674d1fedf9e9dd5c9df5b67d53f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d4afcaad71c13674d1fedf9e9dd5c9df5b67d53f)
- [6b09cdea94c07f77b7cc1dab54d814b87d7bdc97](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6b09cdea94c07f77b7cc1dab54d814b87d7bdc97)
- [97cf20ee109c78d301c0ce10ed98e33b94d5c24f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/97cf20ee109c78d301c0ce10ed98e33b94d5c24f)
- [02407f7d4f28dbc54ad52a9432717c948beef601](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/02407f7d4f28dbc54ad52a9432717c948beef601)

## Improves Presentation of Checkout Layout for Medium Viewports

Modifies the grid within the Storefront checkout layout to improve the presentation for medium viewports.

### Issues

- [ECOMMERCE-5535](https://jira.tools.weblinc.com/browse/ECOMMERCE-5535)

### Pull Requests

- [3003](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3003/overview)

### Commits

- [c37064f4dacde0955e107d77d50845e122ff4350](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c37064f4dacde0955e107d77d50845e122ff4350)
- [e8db5bbf833fe6d931e5b114d23408da7cd0471f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e8db5bbf833fe6d931e5b114d23408da7cd0471f)

## Adds “Full” Text Box to Storefront

Adds a `.text-box--full` modifier in the Storefront.

### Commits

- [23053d53b5206ed445f290c2aeffce2cccfc007b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/23053d53b5206ed445f290c2aeffce2cccfc007b)

## Adds Storefront Link within Admin

Adds a Storefront link within the Admin for convenient navigation between the two UIs.

### Issues

- [ECOMMERCE-5596](https://jira.tools.weblinc.com/browse/ECOMMERCE-5596)

### Commits

- [f7d7b1a05645cb788916db69f7d08de7fe282103](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f7d7b1a05645cb788916db69f7d08de7fe282103)

## Adds Helper in Admin for Product Bulk Action Options

Adds the `catalog_product_bulk_action_options` helper in the Admin, which cleans up the products index view in the Admin and allows for easier extension of product bulk action options.

### Pull Requests

- [3042](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3042/overview)

### Commits

- [db1a9da4bd71fa536c46d8cf4609f4c8ab059256](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/db1a9da4bd71fa536c46d8cf4609f4c8ab059256)
- [8a5c5a449ff56731144dca629d05eba1ad174dbb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8a5c5a449ff56731144dca629d05eba1ad174dbb)

## Improves Generation of IDs for Copied Products

Modifies the “copy product” workflow in the Admin to encourage unique IDs for copied products. The previous implementation generated IDs that were very similar and caused issues with Workarea recommendations.

### Issues

- [ECOMMERCE-4855](https://jira.tools.weblinc.com/browse/ECOMMERCE-4855)

### Pull Requests

- [3025](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3025/overview)

### Commits

- [c53acfac4c11cf49bfada2e2efe0baa343cd5a63](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c53acfac4c11cf49bfada2e2efe0baa343cd5a63)
- [2f4b4cc4a3b673933c7176e435d2918d938aa464](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2f4b4cc4a3b673933c7176e435d2918d938aa464)

## Prevents Multiple Submissions of Image Upload Forms

Disables the buttons for adding product images and content assets in the Admin to prevent additional, unintentional form submissions.

### Issues

- [ECOMMERCE-5187](https://jira.tools.weblinc.com/browse/ECOMMERCE-5187)

### Pull Requests

- [2938](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2938/overview)

### Commits

- [256437b4f8c8e42d412ab107c70abecb93679937](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/256437b4f8c8e42d412ab107c70abecb93679937)
- [a287cdcb87be64d34dc8d5e8d76dbee9810636f5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a287cdcb87be64d34dc8d5e8d76dbee9810636f5)

## Improves Presentation of the Current Release “Reminder”

Improves the UI that is shown to remind an admin they have a current release selected in the Admin. Updates the UI to more closely match the overall look and feel of the Admin.

### Issues

- [ECOMMERCE-5423](https://jira.tools.weblinc.com/browse/ECOMMERCE-5423)

### Pull Requests

- [2914](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2914/overview)

### Commits

- [d787c63f80d1fea00279e5641f7588156882159b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d787c63f80d1fea00279e5641f7588156882159b)
- [027d52327e49823453b2e3e9c53f9683d1d95016](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/027d52327e49823453b2e3e9c53f9683d1d95016)

## Groups Categories within Product Admin

Improves the listing of categories on product Admin screens by grouping the categories by type (featured or rules-based).

### Issues

- [ECOMMERCE-4449](https://jira.tools.weblinc.com/browse/ECOMMERCE-4449)

### Pull Requests

- [3051](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3051/overview)

### Commits

- [050354ea30c0626293e2a78fd769be1612d5487b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/050354ea30c0626293e2a78fd769be1612d5487b)
- [52d9189e9ed0ca8ab835d27640e35f796a125af5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/52d9189e9ed0ca8ab835d27640e35f796a125af5)

## Improves New Block Button in Admin

Improves display of `.new-block-button` component in Admin and adds related inline help text.

### Issues

- [ECOMMERCE-5348](https://jira.tools.weblinc.com/browse/ECOMMERCE-5348)

### Pull Requests

- [2945](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2945/overview)

### Commits

- [2c04aa0c8b31dd849d2e0b4560e2d5f43b35b8dc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c04aa0c8b31dd849d2e0b4560e2d5f43b35b8dc)
- [035dfbc07601494e924085736d0e245c8f6d0ca9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/035dfbc07601494e924085736d0e245c8f6d0ca9)
- [25bc91cda25b7984c76e9d0f960f7d46b93abb53](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/25bc91cda25b7984c76e9d0f960f7d46b93abb53)

## Adds Field to Refine Admin Searches

Adds a field to the Admin search results UI to refine the search terms.

### Issues

- [ECOMMERCE-5157](https://jira.tools.weblinc.com/browse/ECOMMERCE-5157)

### Commits

- [9a1fa5ec64272ccadf3083a12cdda0bc24dc1e73](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a1fa5ec64272ccadf3083a12cdda0bc24dc1e73)

## Updates Display Order of Admin Order Items to Match Storefront

Updates the Admin order view model to display the order items “by newest”, which is how they are ordered in the Storefront.

### Issues

- [ECOMMERCE-5262](https://jira.tools.weblinc.com/browse/ECOMMERCE-5262)

### Pull Requests

- [2824](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2824/overview)

### Commits

- [4cfb8ce8e229cba27233ea4c215a8a7857b94296](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4cfb8ce8e229cba27233ea4c215a8a7857b94296)
- [6e3709ee719e13ff8690058b38b549e6e97f086f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6e3709ee719e13ff8690058b38b549e6e97f086f)

## Adds Tracking & Display of User “Created By”

Stores the ID of the creating user on the created user when a user is created through the Admin. Lists “Created By” in the user attributes Admin screens when the ID is present.

### Issues

- [ECOMMERCE-4844](https://jira.tools.weblinc.com/browse/ECOMMERCE-4844)

### Pull Requests

- [3053](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3053/overview)

### Commits

- [194502a97b80a9e45decaa09875f7bc8c69cfb94](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/194502a97b80a9e45decaa09875f7bc8c69cfb94)
- [a26110b9d5c42245e44adfa317bb3404538a1c31](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a26110b9d5c42245e44adfa317bb3404538a1c31)

## Adds Store Credit Field to “Create Customer” Workflow

Allows administrators to add store credit when creating a new customer account through the Admin.

### Issues

- [ECOMMERCE-4843](https://jira.tools.weblinc.com/browse/ECOMMERCE-4843)
- [ECOMMERCE-5652](https://jira.tools.weblinc.com/browse/ECOMMERCE-5652)

### Pull Requests

- [3077](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3077/overview)
- [3085](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3085/overview)

### Commits

- [197f70e1242e0eb27d6c056ce8f6dd58a4a2fe2d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/197f70e1242e0eb27d6c056ce8f6dd58a4a2fe2d)
- [76d07413e4e66f8ae9c54c93335627a193330162](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/76d07413e4e66f8ae9c54c93335627a193330162)
- [b3ac46b488bb26b66372c4668faa98e384c1844c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3ac46b488bb26b66372c4668faa98e384c1844c)
- [1fc45ee8d2db4ccb0b5851fc938659bc12b06825](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1fc45ee8d2db4ccb0b5851fc938659bc12b06825)

## Adds Featured Products Release Preview Warning Message

Adds a warning message to the featured products Admin screens when there is a current release, because featured products for a release do not show when previewing the release in the Storefront.

### Issues

- [ECOMMERCE-5175](https://jira.tools.weblinc.com/browse/ECOMMERCE-5175)

### Pull Requests

- [3065](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3065/overview)

### Commits

- [5939bcc58625dc9be39517c230d1fb208d169acd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5939bcc58625dc9be39517c230d1fb208d169acd)
- [18cbe1d516e49bf2546042927e0ba8fdab93b225](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/18cbe1d516e49bf2546042927e0ba8fdab93b225)

## Improves Consistency of Admin Cards' “Empty” State

Updates several Admin partials to display an “empty” state consistent with other Admin cards.

### Issues

- [ECOMMERCE-5259](https://jira.tools.weblinc.com/browse/ECOMMERCE-5259)

### Pull Requests

- [2819](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2819/overview)

### Commits

- [f9fc8c5711029fd492c8a2a8ccbbeb2d08ed7a65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f9fc8c5711029fd492c8a2a8ccbbeb2d08ed7a65)
- [c559c07c7e88a1c365c24c4830d3d51becb3d7c1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c559c07c7e88a1c365c24c4830d3d51becb3d7c1)

## Adds Confirmation to Delete Product Images

Adds a confirmation prompt to the delete action within the product images Admin index.

### Issues

- [ECOMMERCE-5188](https://jira.tools.weblinc.com/browse/ECOMMERCE-5188)

### Pull Requests

- [2969](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2969/overview)

### Commits

- [ea45e2928707fe98139d8cf707f840aa7ec8171c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ea45e2928707fe98139d8cf707f840aa7ec8171c)
- [3ad20665d96eeef20dac1445b2361fbd7f819d2f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3ad20665d96eeef20dac1445b2361fbd7f819d2f)

## Fixes Display of Pricing within Admin Data Pairs

Modifies styling of table cells within Admin _data-pairs_ so that prices within these components are aligned as expected.

### Issues

- [ECOMMERCE-5270](https://jira.tools.weblinc.com/browse/ECOMMERCE-5270)

### Commits

- [54ae05c4146c92ab062eac9d14a7d9288c4b43a0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/54ae05c4146c92ab062eac9d14a7d9288c4b43a0)

## Fixes Bulk Action Exports Workflow Bar

Adds missing information to workflow bar for bulk action exports in the Admin.

### Issues

- [ECOMMERCE-5264](https://jira.tools.weblinc.com/browse/ECOMMERCE-5264)

### Pull Requests

- [3006](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3006/overview)

### Commits

- [1efceddc1a488505c2d00c71c0cced0c726c36de](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1efceddc1a488505c2d00c71c0cced0c726c36de)
- [0356c79502deaf5184c684a65ec9d9738c8c1afc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0356c79502deaf5184c684a65ec9d9738c8c1afc)

## Fixes Cursor Pointer Style for Links Within Admin Headers

Ensures all links within Admin _header_ components display with a “pointer” cursor style.

### Issues

- [ECOMMERCE-5257](https://jira.tools.weblinc.com/browse/ECOMMERCE-5257)

### Pull Requests

- [2816](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2816/overview)

### Commits

- [ddf741ffc1118d1514b8f11d9da34c1d9f41c8c4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ddf741ffc1118d1514b8f11d9da34c1d9f41c8c4)
- [318ad6be1ade382521ff115eb94e04e5efb306aa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/318ad6be1ade382521ff115eb94e04e5efb306aa)

## Adds Testing of Checkout Price Updating

Adds test assertions to cover the updating of pricing in checkout.

### Issues

- [ECOMMERCE-5520](https://jira.tools.weblinc.com/browse/ECOMMERCE-5520)

### Pull Requests

- [2987](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2987/overview)

### Commits

- [29cc8b887994b51bbc8dd8d2bc6a0aabcbb6f364](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/29cc8b887994b51bbc8dd8d2bc6a0aabcbb6f364)
- [d5b711dad9187a997ca07c2fa0bfce568a3a26e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5b711dad9187a997ca07c2fa0bfce568a3a26e6)

## Removes Remaining References to Product Sharing

Removes vestigial references to product sharing, which was moved to a plugin in Workarea 3.0.

### Issues

- [ECOMMERCE-5215](https://jira.tools.weblinc.com/browse/ECOMMERCE-5215)

### Pull Requests

- [2964](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2964/overview)

### Commits

- [2054a98f2ed433e74268290f691b07d4c3b2601d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2054a98f2ed433e74268290f691b07d4c3b2601d)
- [6432da6400b2fe1e92bd6c01af46f43ea3d16bac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6432da6400b2fe1e92bd6c01af46f43ea3d16bac)

## Adds Append Points

Adds many append points for platform extension. Other changes listed in these release notes may also include the addition of append points. The changes listed here exist primarily to add append points.

### Issues

- [ECOMMERCE-5252](https://jira.tools.weblinc.com/browse/ECOMMERCE-5252)
- [ECOMMERCE-5253](https://jira.tools.weblinc.com/browse/ECOMMERCE-5253)
- [ECOMMERCE-5444](https://jira.tools.weblinc.com/browse/ECOMMERCE-5444)

### Pull Requests

- [2817](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2817/overview)
- [2899](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2899/overview)
- [2936](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2936/overview)
- [2937](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2937/overview)
- [3079](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3079/overview)

### Commits

- [97a0145de54cdf60265fb532d615577bafa06e6d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/97a0145de54cdf60265fb532d615577bafa06e6d)
- [8ebda4919fdd3dfd8a927ae3f1ac8d96ae612190](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8ebda4919fdd3dfd8a927ae3f1ac8d96ae612190)
- [974a7c3d3bdd2c3ce0217c560a74d64af9846151](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/974a7c3d3bdd2c3ce0217c560a74d64af9846151)
- [fa28023a77f8c589782ee9328e7c226fa7c52d5f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fa28023a77f8c589782ee9328e7c226fa7c52d5f)
- [a09f036254f23e9e6da6f0eb80c8cb4f6b7d10b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a09f036254f23e9e6da6f0eb80c8cb4f6b7d10b7)
- [699545ccb2da519b4a07222c3deecb704e0db51a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/699545ccb2da519b4a07222c3deecb704e0db51a)
- [3b934b516a3d9d915a95ea737ad108d4b27f74bd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3b934b516a3d9d915a95ea737ad108d4b27f74bd)
- [6c70a308a4e103315dacd78b7d0085366dbf07f3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6c70a308a4e103315dacd78b7d0085366dbf07f3)
- [c5bac72c748204866c221331d292ed948a821e6e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c5bac72c748204866c221331d292ed948a821e6e)
- [ccaae4d8688754303425e05ebe410e3489d6c596](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ccaae4d8688754303425e05ebe410e3489d6c596)
- [a13459d6adc8aa27fc607be3bfe44f611693f529](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a13459d6adc8aa27fc607be3bfe44f611693f529)
- [4967970ce80dab64fc945b601e9858dcd892aed0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4967970ce80dab64fc945b601e9858dcd892aed0)
- [45930c48197b133defd9e896db76c8a8799085ff](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/45930c48197b133defd9e896db76c8a8799085ff)

