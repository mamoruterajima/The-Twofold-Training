Rails.application.routes.draw do
  get "home/index"
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # ゲストログイン用のルーティングを追加
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end

  resources :training_logs do
    get :last_record, on: :collection
  end

  root "training_logs#index"
end