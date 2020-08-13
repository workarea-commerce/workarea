module Workarea
  class Inquiry
    include ApplicationDocument

    field :name, type: String
    field :email, type: String
    field :order_id, type: String
    field :subject, type: String
    field :message, type: String

    validates :subject, length: { maximum: 1_000 }
    validates :message, presence: true,
                        length: { maximum: 2_000 }

    validate :subject_exists

    def full_subject
      I18n.t('workarea.inquiry.subjects')[subject.optionize.to_sym].presence ||
        Workarea.config.inquiry_subjects[subject]
    end

    private

    def subject_exists
      unless subject.blank? ||
        Workarea.config.inquiry_subjects.keys.include?(subject)
        errors.add(:subject, I18n.t('errors.messages.inclusion'))
      end
    end
  end
end
