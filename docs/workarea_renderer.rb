require "middleman-core/renderers/redcarpet"

class WorkareaRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
  def header(text, header_level)
    id = text.gsub(/<[^>]*>/, ' ').squeeze(' ').parameterize
    "<h%s id=\"%s\">%s</h%s>" % [header_level, id, text, header_level]
  end
end
