module Workarea
  module ApplicationDocument
    extend ActiveSupport::Concern

    include Mongoid::Document
    include Mongoid::AuditLog
    include Mongoid::Timestamps
    include Sidekiq::Callbacks
    include GlobalID::Identification

    included do
      before_validation :clean_array_fields
      before_create :ensure_default_locale_values
    end

    def releasable?
      is_a?(Releasable)
    end

    private

    def ensure_default_locale_values
      return if I18n.locale == I18n.default_locale

      default_locale = I18n.default_locale.to_s

      self.class.localized_fields.each do |name, field|
        translations = send("#{name}_translations")

        unless translations.key?(default_locale)
          send(
            "#{name}_translations=",

            # Grab the current value because we need something here. Fallbacks
            # don't work for the default locale if it doesn't exist.
            translations.merge(
              default_locale => translations[I18n.locale.to_s]
            )
          )
        end
      end
    end

    def clean_array_fields
      # Trying to modify the attributes of a document that is set to
      # to be destroyed will throw an error, as the attributes Hash is frozen.
      # This can occur when an instance of a model has embedded documents that
      # have been marked for deletion.
      return if self.destroyed?

      self.class.fields.each do |name, field|
        next unless field.type == ::Array

        if field.localized?
          translations = send("#{name}_translations")

          cleaned = translations.each_with_object({}) do |(locale, original), memo|
            if original.nil?
              memo[locale] = nil
              next
            end

            memo[locale] = original.reject(&:blank?)
          end

          send("#{name}_translations=", cleaned)
        else
          next unless original = send(name)

          send("#{name}=", original.reject(&:blank?))
        end
      end
    end
  end
end
