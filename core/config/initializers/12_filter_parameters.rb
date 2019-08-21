Rails.application.config.filter_parameters += [
  :password,
  :number,
  :new_card,
  :cvv,
  :first_name,
  :last_name,
  :street,
  :phone_number,
  :token,
  :reference,
  :gateway_id
]
