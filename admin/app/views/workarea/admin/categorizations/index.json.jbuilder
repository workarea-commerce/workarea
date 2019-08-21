json.results @product.categories do |category|
  json.label category.name
  json.value category.id.to_s
  json.sparkline_data sparkline_analytics_data_for(
    category.insights.orders_sparkline
  )
  json.top category.insights.top?
  json.title category.breadcrumb_string
end
