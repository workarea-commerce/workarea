module Workarea::UrlToken
  extend ActiveSupport::Concern

  include ActiveRecord::SecureToken

  included do
    field :token, type: String
    index({ token: 1 }, { unique: true })
    has_secure_token
    before_validation :ensure_token_exists
  end

  module ClassMethods
    def find_by_token(token)
      find_by(token: token) rescue nil
    end
  end

  private

  def ensure_token_exists
    self.token = self.class.generate_unique_secure_token if token.blank?
  end
end
