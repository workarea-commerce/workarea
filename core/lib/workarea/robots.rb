module Workarea
  module Robots
    REGEX = /\b(80legs|Aboundex|AhrefsBot|alexa|Baidu|bing|CCBot|covario|discobot|exabot|ezooms|FairShare|fatbot|Gigabot|goodzer|Googlebot|hailoobot|IstellaBot|jikespider|libwww-perl|lwp-trivial|LYCOSA|mahonie|msnbot|MJ12bot|nessus|Nutch|SBIder|scanalert|ScoutJet|SeznamBot|ShopWiki|SiteUptime|Slurp|sogou|UnwindFetchor|WBSearchBot|WordPress|yandexbot|ZIBB|ZyBorg)\b/i

    def self.is_robot?(user_agent)
      user_agent.to_s =~ REGEX
    end
  end
end
