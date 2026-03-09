# frozen_string_literal: true

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

    # Rails/ActiveRecord expose change tracking helpers like:
    #   saved_change_to_name?
    #   saved_change_to_name
    #   name_before_last_save
    # Mongoid exposes similar information via #previous_changes, but it does not
    # provide the same convenience methods. Some parts of Workarea (and plugins)
    # expect the Rails API when running under newer Rails versions.
    #
    # Provide a small, backwards-compatible shim that works for Mongoid 7/8.
    #
    # @see ActiveModel::Dirty (ActiveRecord)
    def saved_change_to_attribute?(attr_name)
      return super if defined?(super)
      previous_changes.key?(attr_name.to_s)
    end

    def saved_change_to_attribute(attr_name)
      return super if defined?(super)
      previous_changes[attr_name.to_s]
    end

    def attribute_before_last_save(attr_name)
      return super if defined?(super)

      change = previous_changes[attr_name.to_s]
      change.is_a?(Array) ? change.first : nil
    end

    def method_missing(method_name, *args, &block)
      name = method_name.to_s

      if name =~ /\Asaved_change_to_(.+)\?\z/
        return saved_change_to_attribute?(Regexp.last_match(1))
      elsif name =~ /\Asaved_change_to_(.+)\z/
        return saved_change_to_attribute(Regexp.last_match(1))
      elsif name =~ /\A(.+)_before_last_save\z/
        return attribute_before_last_save(Regexp.last_match(1))
      end

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      name = method_name.to_s

      name.start_with?('saved_change_to_') ||
        name.end_with?('_before_last_save') ||
        super
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
