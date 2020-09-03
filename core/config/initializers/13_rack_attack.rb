# These settings and configuration were copied from
# https://github.com/kickstarter/rack-attack/wiki/Example-Configuration
#
# When copied, they stated:
# "You'll be safe from 95% of bad requests. This won't stop sophisticated
# hackers, but at least you can sleep more soundly knowing that your application
# isn't going to be accidentally taken down by a misconfigured web scraper in
# the middle of the night."
#
class Rack::Attack

  #
  # Disable +Rack::Attack+ for Kubernetes health checks. Kubernetes uses
  # a non-standard IP address to access the app server internally, and
  # causes errors when being loaded into `IPAddr`. This safelist will
  # prevent the IPs from going through `IPAddr` at all, thus preventing
  # the error.
  #
  # Key: "rack::attack:ignore/k8s"
  KUBERNETES_IP_ADDRESS = '127.0.0.1:0'

  safelist('ignore/k8s') do |request|
    request.ip == KUBERNETES_IP_ADDRESS
  end

  #
  # Disable +Rack::Attack+ when an admin is signed in. Prevents issues
  # while large amounts of admins (such as a customer service
  # department) are accessing the site with the same IP.
  #
  # Key: "rack::attack:ignore/cookies/admin"
  safelist('ignore/admins') do |request|
    request.env['workarea.visit']&.admin?
  end

  #
  # Disable +Rack::Attack+ for configured IP addresses
  #
  # Key: "rack::attack:ignore"
  if ENV['WORKAREA_RACK_ATTACK_IGNORE_IP_ADDRESSES'].present?
    IGNORED_IP_ADDRESSES = ENV['WORKAREA_RACK_ATTACK_IGNORE_IP_ADDRESSES']
      .split(',')
      .map { |s| IPAddr.new(s) }

    safelist('ignore') do |request|
      IGNORED_IP_ADDRESSES.any? { |ip| ip.include?(request.ip) }
    end
  end

  #
  # Disable +Rack::Attack+ for IP addresses set via admin configuration
  #
  # Key: "rack::attack:ignore/config"
  safelist('ignore/config') do |request|
    ips = Workarea.config.safe_ip_addresses.map do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        # noop
      end
    end.compact

    ips.any? { |ip| ip.include?(request.ip) }
  end

  #
  # Block all requests from IP addresses set via admin configuration
  #
  # Key: "rack::attack:block/config"
  blocklist('block/config') do |request|
    ips = Workarea.config.blocked_ip_addresses.map do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        # noop
      end
    end.compact

    ips.any? { |ip| ip.include?(request.ip) }
  end

  ### Throttle Spammy Clients ###

  #
  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.current.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', limit: 300, period: 5.minutes) do |request|
    white_listed_paths = %w(/assets /product_images /content_blocks /admin)
    request.ip unless request.path.start_with?(*white_listed_paths)
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.current.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', limit: 5, period: 20.seconds) do |request|
    if request.path == '/login' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.current.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle('logins/email', limit: 5, period: 20.seconds) do |request|
    if request.path == '/login' && request.post?
      # return the email if present, nil otherwise
      request.params['email'].presence
    end
  end

  # Throttle POST requests to /users/account by IP address
  #
  # A malicious user can abuse the signup form to determine email addresses
  # associated to accounts.
  #
  # Key: "rack::attack:#{Time.current.to_i/:period}:signups/ip:#{req.ip}"
  throttle('signups/ip', limit: 5, period: 1.minute) do |request|
    if request.path == '/users/account' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /contact by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:contact/ip:#{req.ip}"
  throttle('contact/ip', limit: 3, period: 1.minute) do |request|
    if request.path == '/contact' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /email_signup by email address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:email_signup/email:#{req.email}"
  throttle('email_signup/email', limit: 10, period: 20.minutes) do |request|
    if request.path == '/email_signup' && request.post?
      # return the email if present, nil otherwise
      request.params['email'].presence
    end
  end

  # Throttle POST requests to /email_signup by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:email_signup/ip:#{req.ip}"
  throttle('email_signup/ip', limit: 10, period: 20.minutes) do |request|
    if request.path == '/email_signup' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /forgot_password by email address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:password_reset/email:#{req.email}"
  throttle('password_reset/email', limit: 10, period: 20.minutes) do |request|
    if request.path == '/forgot_password' && request.post?
      # return the email if present, nil otherwise
      request.params['email'].presence
    end
  end

  # Throttle POST requests to /forgot_password by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:password_reset/ip:#{req.ip}"
  throttle('password_reset/ip', limit: 10, period: 20.minutes) do |request|
    if request.path == '/forgot_password' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /content_security_violations by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:csp_violations/ip:#{req.ip}"
  throttle('csp_violations/ip', limit: 10, period: 10.minutes) do |request|
    if request.path == '/content_security_violations' && request.post?
      request.ip
    end
  end

  # Throttle POST requests to /content_security_violations by blocked uri
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:csp_violations/blocked_uri:#{req.blocked_uri}"
  throttle('csp_violations/blocked_uri', limit: 1, period: 1.hour) do |request|
    if request.path == '/content_security_violations' && request.post?
      # return the blocked_uri if present, nil otherwise
      request.params['blocked_uri'].presence
    end
  end

  # Block IP addresses that are hammering credit card endpoints
  #
  # This can happen when credit card fraudsters are trying to use checkout
  # and/or saved credit card functionality as a way to check whether a card
  # number is usable.
  #
  blocklist('req/credit_cards') do |request|
    Rack::Attack::Allow2Ban.filter(request.ip, maxretry: 10, findtime: 1.hour, bantime: 1.day) do
      request.path =~ /place_order|credit_cards/ && !request.get?
    end
  end

  # Block IP addresses that are hammering promo code endpoints
  #
  # We don't want people trying to brute force promo codes.
  #
  blocklist('req/promo_codes') do |request|
    key = "promo_codes:#{request.ip}"

    Rack::Attack::Allow2Ban.filter(key, maxretry: 10, findtime: 1.hour, bantime: 1.day) do
      !request.get? && request.path =~ /promo_code/
    end
  end
end
