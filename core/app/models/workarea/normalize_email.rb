module Workarea::NormalizeEmail
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_email
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end
end
