module Workarea
  class QueryString
    include GlobalID::Identification

    INVALID_SEARCH_REGEX = /[\]\[:\.;\(\)\{\}^\\\/!~]|<\/?script>|(\s+)?-(\s|$)/

    attr_reader :original
    delegate :present?, :blank?, to: :sanitized

    def self.find(id)
      new(id.humanize(capitalize: false))
    end

    def initialize(original)
      @original = original
    end

    def id
      @id ||= Array(Lingua.stemmer(pieces)).join('_').downcase.gsub(/\W/, '')
    end

    def pieces
      @pieces ||= sanitized.split(/\s/)
    end

    def pretty
      pieces.map(&:downcase).join(' ')
    end

    def phrase?
      pieces.many?
    end

    def sanitized
      @sanitized ||=
        begin
          query = @original
            .to_s
            .gsub(INVALID_SEARCH_REGEX, ' ')
            .strip
            .squeeze(' ')

          query.gsub!('"', '\"') if query.count('"') == 1
          query.gsub!(/(\w)( AND| OR)$/) { "#{::Regexp.last_match(1)}#{::Regexp.last_match(2).downcase}" }

          query
        end
    end

    def all?
      sanitized == '*'
    end

    def short?
      id.length < 3
    end
  end
end
