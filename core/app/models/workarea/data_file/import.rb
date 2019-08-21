module Workarea
  module DataFile
    class Import
      include ApplicationDocument
      include Operation

      field :file_errors, type: Hash, default: {}
      field :error_type, type: String
      field :error_message, type: String
      field :total, type: Integer, default: 0
      field :succeeded, type: Integer, default: 0

      # These scopes used for mailer previews only
      scope :successful, -> { where(file_errors: {}, error_type: nil, :succeeded.gt => 0) }
      scope :failure, -> { where(:file_errors.ne => {}) }
      scope :error, -> { where(:error_type.ne => [nil, '']) }

      before_validation :set_file_type

      def file_name
        super.presence || file_type&.upcase
      end

      def successful?
        !error? && total == succeeded
      end

      def failure?
        !successful?
      end

      def error?
        error_message.present?
      end

      def failed
        total - succeeded
      end

      def process!
        set(started_at: Time.current)
        assert_valid_file_type
        run_callbacks(:process) { format.import! }

      rescue Exception => e
        self.error_type = e.class
        self.error_message = e.message
        raise e

      ensure
        self.completed_at = Time.current
        save!
      end

      def log(index, instance)
        self.total += 1

        if instance.errors.blank? && instance.persisted?
          self.succeeded += 1
        else
          id = instance.new_record? ? index : instance.id
          file_errors[id.to_s] = instance.errors.as_json
        end
      end

      private

      def set_file_type
        return if file.blank?

        extension = file.ext.presence || file.path.split('.').last
        self.file_type = Mime::Type.lookup(file.mime_type).try(:symbol) ||
                            Mime::Type.lookup_by_extension(extension).try(:symbol)
      end

      def assert_valid_file_type
        value = read_attribute(:file_type).presence_in(Workarea.config.data_file_formats)
        raise UnknownFormatError.new if value.blank?
      end
    end
  end
end
