json.results @search.results do |discount|
  json.label discount.name
  json.value discount.id.to_s
  json.sparkline_data sparkline_analytics_data_for(
    discount.insights.orders_sparkline
  )
  json.top discount.insights.top?
end
