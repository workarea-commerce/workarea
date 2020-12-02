module Workarea
  class Metadata
    attr_reader :content, :model

    def self.model_name(klass)
      ActiveModel::Naming.param_key(klass)
    end

    def self.automation_klass(model)
      "Workarea::Metadata::#{model_name(model.class).classify}".constantize
    rescue NameError
      nil
    end

    def self.update(content)
      contentable = content.contentable
      return unless contentable.present?

      metadata_klass = automation_klass(contentable)
      metadata_klass.new(content).update if metadata_klass.present?
    end

    def initialize(content)
      @content = content
      @model = content.contentable
    end

    def update
      return unless Workarea.config.automate_seo_data && content.automate_metadata?

      content.browser_title = title
      content.meta_description = description
      content.save!
    end

    def title
      raise(
        NotImplementedError,
        "#{self.class.name} must implement the #title method"
      )
    end

    def description
      raise(
        NotImplementedError,
        "#{self.class.name} must implement the #description method"
      )
    end

    private

    def max_words
      Workarea.config.meta_description_max_words
    end
  end
end
