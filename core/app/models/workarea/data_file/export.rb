module Workarea
  module DataFile
    class Export
      include ApplicationDocument
      include Operation

      field :query_id, type: String, default: AdminSearchQueryWrapper.new.to_global_id
      field :ids, type: Array, default: []
      field :exclude_ids, type: Array, default: []
      field :emails, type: Array, default: []
      list_field :emails

      validate :emails_are_valid

      def process!
        set(started_at: Time.current)
        run_callbacks(:process) { format.export! }
        update_attributes!(file: tempfile.tap(&:close), completed_at: Time.current)
      end

      def models
        @models ||= AdminQueryOperation.new(attributes)
      end

      private

      def emails_are_valid
        return unless emails.present?

        validator = EmailValidator.new(attributes: attributes)
        emails.each do |email|
          validator.validate_each(self, :emails, email)
          break if errors[:emails].any?
        end
      end
    end
  end
end
