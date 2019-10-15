json.results @results do |user|
  json.label user.name
  json.value user.id
end

json.mentions @results do |user|
  json.id user.id
  json.name user.name
  json.email user.email
  json.lookup "#{user.name} (#{user.email})"
  json.fillAttr user.email.split('@').first
end
