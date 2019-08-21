json.results @search.results do |page|
  json.label page.name
  json.value page.id.to_s
  json.id page.id.to_s
  json.name page.name
  json.tags page.tags
end
