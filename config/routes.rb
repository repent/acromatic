Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users, controllers: { registrations: 'registrations' }
  resources :definitions do
    member do
      get 'sentence_case'
      get 'titlecase'
    end
  end
  resources :dictionaries do
    member do
      get 'merge_duplicates'
    end
  end
  resources :acronyms
  resources :documents

  get 'users#sign_up' => 'document#new'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'documents#new'

  # Static content
  get ':action' => 'static#:action'
end
