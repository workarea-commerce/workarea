json.logged_in logged_in?
json.cart_quantity current_order.quantity
json.admin !!current_admin
json.impersonating impersonating?
json.browsing_as_guest admin_browsing_as_guest?
json.csrf_param request_forgery_protection_token.to_s
json.csrf_token form_authenticity_token
json.append_partials('storefront.current_user')
