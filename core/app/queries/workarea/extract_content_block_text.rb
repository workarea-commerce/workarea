module Workarea
  class ExtractContentBlockText
    def initialize(blocks)
      @blocks = Array(blocks)
    end

    def text
      @blocks.reduce('') do |memo, block|
        memo << ' ' unless memo.blank?
        memo << extract_text(block.data)
      end
    end

    private

    def extract_text(data)
      data.values.reduce('') do |memo, value|
        value = value.to_s

        if value.scan(/[\p{Alnum}\-\_\:\/\/\.']+/).size >= min_words
          memo << ' ' unless memo.blank?
          memo << ActionController::Base.helpers.strip_tags(value)
        else
          memo
        end
      end
    end

    def min_words
      Workarea.config.minimum_content_search_words
    end
  end
end
