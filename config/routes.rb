Rails.application.routes.draw do
  resources :user_mails, only: [:index,:show] do
    get :download_attachment, on: :member
  end

  resources :mail_accounts do
    post :pull_imap, on: :member
  end
  devise_for :users

  root to:'mail_accounts#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
