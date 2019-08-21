class Premailer
  def convert_to_text(html, line_length = 65, from_charset = 'UTF-8')
    html.gsub!(/<script.*script>/m, '')
    super(html, line_length, from_charset)
  end
end
