Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'rainydays#index'
  get 'rainydays/cloud_vision'
  get '/cloud_vision', to: 'rainydays#cloud_vision', as: 'cloud_vision'

  # get 'rainydays/background' => "rainydays#background"
  # get 'rainydays/resources' => "rainydays#resources"
end
