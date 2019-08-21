module Workarea
  module DataFile
    class Format
      attr_reader :operation
      delegate_missing_to :operation

      def initialize(operation = nil)
        @operation = operation
      end

      def slug
        self.class.name.demodulize.underscore
      end

      def unit
        I18n.t("workarea.data_file.#{self.class.name.demodulize.underscore}.unit")
      end

      # This method exists for showing sample file content and for testing.
      #
      # All the funkiness is so this doesn't have to be written for each format.
      # Simply implement your #export method and #serialize will come along for
      # the ride.
      #
      # @param [Object]
      # @return [String]
      #
      def serialize(models)
        file = Tempfile.new(self.class.name)
        copy = self.class.new
        scoped_models = Array.wrap(models)

        copy.define_singleton_method(:models) { scoped_models }
        copy.define_singleton_method(:tempfile) { file }
        copy.export!

        file.rewind
        file.read
      ensure
        file.close
        file.unlink
      end

      def clean_ignored_fields(object)
        if object.is_a?(Hash)
          Hash[
            object.except(*Workarea.config.data_file_ignored_fields).map do |key, value|
              [key, clean_ignored_fields(value)]
            end
          ]
        elsif object.is_a?(Array)
          object.map { |o| clean_ignored_fields(o) }
        else
          object
        end
      end

      # Special case for Users, since +password+ is a hashed field. Set
      # the password attribute from the column if given, otherwise
      # assign a randomized password to the User so they can be
      # imported via CSV/JSON without knowing what the hashed result of
      # their intended password is.
      def assign_password(model, password = nil)
        return unless model.is_a?(User::Passwords)
        return if model.persisted? && password.blank?

        model.password = if password.present?
                           password
                         elsif model.new_record?
                           "#{SecureRandom.hex(10)}_aA1"
                         end
      end

      # Return the class specified by the +_type+ attribute, or the
      # default +model_class+ for the operation.
      #
      # @param [Hash] attrs - Attributes from the row
      # @return [Class] Model class constant
      def model_class_for(attrs = {})
        type = attrs.symbolize_keys.slice(:type, :_type).values.first
        type&.constantize || model_class
      end
    end
  end
end
