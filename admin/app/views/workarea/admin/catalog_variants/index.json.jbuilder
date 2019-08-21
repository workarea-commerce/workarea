json.results @variants do |variant|
  json.label variant.name
  json.value variant.sku
end
