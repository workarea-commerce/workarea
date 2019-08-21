json.results @results do |user|
  json.label user.name
  json.value user.id
end
