Rails.application.routes.draw do
  mount Workarea::Core::Engine => '/workarea'
  mount Workarea::Admin::Engine => '/admin', as: 'admin'
  mount Workarea::Storefront::Engine => '/', as: 'storefront'

  # For helper specs
  get '__test', to: 'tests#index' if Rails.env.test?
end
