module Workarea
  class CopyPage
    def initialize(page, attrs = {})
      @page = page
      @attributes = Workarea.config.page_copy_default_attributes.merge(attrs)
      @page_copy = nil
    end

    def perform
      copy_page
      check_copied_page

      unless @page_copy.errors.any?
        save_content
        @page_copy.save!
      end

      @page_copy
    end

    def copy_page
      @page_copy = @page.clone
      @page_copy.attributes = @attributes
      @page_copy.copied_from = @page
    end

    def check_copied_page
      existing_page = Catalog::Page.find(@page_copy.id) rescue nil

      if existing_page.present?
        @page_copy.errors.add(
          :id,
          I18n.t('workarea.errors.messages.must_be_unique')
        )
      end
    end

    def save_content
      content_clone = @page.content.clone
      content_clone.contentable_id = @page_copy.id
      content_clone.blocks = @page.content.blocks.map(&:clone)
      content_clone.save!
    end
  end
end
