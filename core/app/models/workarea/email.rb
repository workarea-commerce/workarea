# TODO v4 get rid of this
module Workarea::Email
  # Add an email address to the email sign ups list
  #
  # @param email [String]
  # @return [self]
  #
  def self.signup(email)
    unless email.blank?
      Workarea::Email::Signup.create(email: email)
    end
  end

  def self.signed_up?(email)
    Workarea::Email::Signup.where(email: email).exists?
  end

  def self.unsignup(email)
    Workarea::Email::Signup.where(email: email).destroy
  end
end
