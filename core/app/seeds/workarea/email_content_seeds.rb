module Workarea
  class EmailContentSeeds
    def perform
      puts 'Adding content emails...'
      Content::Email.create!(type: 'order_confirmation', content: 'Thank you for shopping with us!')
      Content::Email.create!(type: 'order_reminder', content: "You didn't finish checking out!")
      Content::Email.create!(type: 'account_creation', content: 'Welcome!')
      Content::Email.create!(type: 'password_reset', content: 'Reset Your Password')
    end
  end
end
