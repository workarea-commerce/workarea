module Workarea
  module DataFile
    module Operation
      extend ActiveSupport::Concern

      included do
        extend Dragonfly::Model

        field :model_type, type: String
        field :file_name, type: String
        field :file_uid, type: String
        field :file_type, type: String
        field :started_at, type: Time
        field :completed_at, type: Time
        field :created_by_id, type: String

        index(
          { created_at: 1 },
          { expire_after_seconds: Workarea.config.data_file_operation_ttl.seconds.to_i }
        )

        dragonfly_accessor :file, app: :workarea
        define_model_callbacks :process
        validates :model_type, presence: true
      end

      def name
        model_class.model_name.param_key.titleize
      end

      def model_class
        @model_class ||= model_type.constantize
      end

      def file_type
        super.presence_in(Workarea.config.data_file_formats) ||
          Workarea.config.data_file_formats.first
      end

      def mime_type
        "#{MIME::Types.type_for(file_type).first.to_s}; charset=utf-8"
      end

      def process!
        raise NotImplementedError
      end

      def complete?
        completed_at.present?
      end

      def sample_file_content
        format.serialize(samples)
      end

      def samples
        @samples ||= model_class.limit(Workarea.config.data_file_sample_size).to_a
      end

      def tempfile
        @tempfile ||= File.open(Pathname.new(Dir.tmpdir).join(generate_file_name), 'w')
      end

      def format
        @format ||= "Workarea::DataFile::#{file_type.camelize}".constantize.new(self)
      end

      private

      def generate_file_name
        "#{model_class.model_name.route_key}_#{Time.current.to_s(:export)}.#{file_type}"
      end
    end
  end
end
