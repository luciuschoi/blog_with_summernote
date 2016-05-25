Rails.application.routes.draw do
  post 'uploads' => 'uploads#create'
  delete 'delete_file' => 'uploads#destroy'
  resources :posts


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
