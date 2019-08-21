---
title: Configure Logins & Authentication
created_at: 2018/09/17
excerpt: Workarea provides several configuration options related to user login and authentication.
---

# Configure Logins & Authentication

Workarea provides several configuration options related to user login and authentication.

| Config | Description |
| --- | --- |
| `config.allowed_login_attempts` | Number of failed login attempts before locking out the user |
| `config.lockout_period` | How long an account is locked out after making too many failed login attempts |
| `config.password_lifetime` | How long an adminstrator's password lasts |
| `config.password_history_length` | How many passwords to keep and validate against |
| `config.password_strength` | Password requirement level: `:weak`, `:medium`, or `:strong` |

your\_app/config/initializers/workarea.rb:

```
# ...

Workarea.configure do |config|

  # ...

  config.allowed_login_attempts = 6

  config.lockout_period = 30.minutes

  config.password_lifetime = 90.days

  config.password_history_length = 4

  config.password_strength = :weak

  # ...

end
```


