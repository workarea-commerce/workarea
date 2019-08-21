json.results @search.results do |product|
  json.label product.name
  json.value product.id
  json.sparkline_data sparkline_analytics_data_for(
    product.insights.orders_sparkline
  )
  json.top product.insights.top?
  json.trending product.insights.trending?
end
