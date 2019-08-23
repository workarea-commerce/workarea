# Security policy

Workarea takes web security very seriously. This means including features to protect application makers from common issues like CSRF, Script Injection, and the like. But it also means a clear policy on how to report vulnerabilities and receive updates when patches to those are released.

## Supported versions

For all security issues, all releases in the current major series will receive patches and new versions. This is currently 3.4.x, 3.3.x, 3.2.x, 3.1.x, and 3.0.x. When a release series is no longer supported, it’s your own responsibility to deal with bugs and security issues. We may provide backports of the fixes and publish them to git, however there will be no new versions released. If you are not comfortable maintaining your own versions, you should upgrade to a supported version. The classification of a security issue is determined by the Workarea core team.

## Reporting a vulnerability

All security bugs in Workarea should be reported to [security@workarea.com](mailto:security@workarea.com). Your report will be acknowledged within 24 hours, and you’ll receive a more detailed response within 48 hours indicating the next steps in handling your report.

After the initial reply to your report the security team will endeavor to keep you informed of the progress being made towards a fix and full announcement. These updates will be sent at least every five days, in reality this is more likely to be every 24-72 hours.

If you have not received a reply to your email within 72 hours, or have not heard from the security team for the past five days there are a few steps you can take:

1. Send an email to the support team ([support@workarea.com](mailto:support@workarea.com)).
2. Contact the core team through our [community Slack channel](https://workarea-community.slack.com)
3. Reach out to a [member of the product team](https://github.com/workarea-commerce/workarea/blob/master/CONTRIBUTORS.md) directly.

## Disclosure process

1. Security report received and is assigned a primary handler. This person will coordinate the fix and release process. Problem is confirmed and a list of all affected versions is determined. Code is audited to find any potential similar problems.

2. Fixes are prepared for all releases which are still supported. These fixes are not committed to the public repository but rather held locally pending the announcement.

3. A suggested embargo date for this vulnerability is chosen.

4. On the embargo date, the changes are pushed to the public repository and new gems released to rubygems. The Workarea security mailing list is sent a copy of the announcement, and a copy of the announcement will be published to the developer forum.

Typically the embargo date will be within 72 hours from when a fix has been identified, however this may vary depending on the severity of the bug or difficulty in applying a fix. This process can take some time, especially when coordination is required with maintainers of other projects. Every effort will be made to handle the bug in as timely a manner as possible, however it’s important that we follow the release process above to ensure that the disclosure is handled in a consistent manner.

## Receiving disclosures

The best way to receive all the security announcements is to subscribe to the Workarea Security mailing list. The mailing list is very low traffic, and it receives the public notifications the moment the embargo is lifted. No one outside the core team and the initial reporter will be notified prior to the lifting of the embargo. We regret that we cannot make exceptions to this policy for high traffic or important sites, as any disclosure beyond the minimum required to coordinate a fix could cause an early leak of the vulnerability.
If you have any suggestions to improve this policy, please send an email to [security@workarea.com](mailto:security@workarea.com).
