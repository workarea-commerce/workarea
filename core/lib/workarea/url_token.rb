module Workarea::UrlToken
  extend ActiveSupport::Concern

  # Workarea models using this concern are Mongoid documents, not ActiveRecord
  # models. Rails 7.2 changed internals of ActiveRecord::SecureToken (it now
  # assumes ActiveRecord APIs like `ActiveRecord.generate_secure_token_on`), so
  # we provide a small, datastore-agnostic token generator here instead.

  included do
    field :token, type: String
    index({ token: 1 }, { unique: true })
    before_validation :ensure_token_exists
  end

  module ClassMethods
    def find_by_token(token)
      find_by(token: token) rescue nil
    end

    # Generate a token that is unique for this collection.
    def generate_unique_secure_token
      loop do
        token = SecureRandom.urlsafe_base64(18)
        break token unless where(token: token).exists?
      end
    end
  end

  private

  def ensure_token_exists
    self.token = self.class.generate_unique_secure_token if token.blank?
  end
end
