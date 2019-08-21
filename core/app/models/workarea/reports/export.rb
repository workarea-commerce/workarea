module Workarea
  module Reports
    class Export
      include ApplicationDocument
      extend Dragonfly::Model

      field :report_type, type: String
      field :report_params, type: Hash, default: {}
      field :emails, type: Array, default: []
      field :file_name, type: String
      field :file_uid, type: String
      field :started_at, type: Time
      field :completed_at, type: Time
      field :created_by_id, type: String

      index(
        { created_at: 1 },
        { expire_after_seconds: Workarea.config.reports_export_ttl.seconds.to_i }
      )

      dragonfly_accessor :file, app: :workarea
      list_field :emails

      validates :report_type, presence: true
      validates :emails, presence: true
      validate :emails_are_valid

      def name
        report_type.titleize
      end

      def process!
        set(started_at: Time.current)
        CSV.open(temp_path, 'w') { |csv| yield(csv) }
        update_attributes!(file: temp_path, completed_at: Time.current)
      end

      def report
        klass = "Workarea::Reports::#{report_type.camelize}".constantize
        report = klass.new(report_params)
      end

      def temp_path
        @temp_path ||= Pathname
          .new(Dir.tmpdir)
          .join("#{report_type}_#{Time.current.to_s(:export)}.csv")
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
