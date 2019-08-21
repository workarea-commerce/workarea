class URI::Generic
  def request_uri
    str = @path
    str += '?' + @query if @query
    str
  end
end
