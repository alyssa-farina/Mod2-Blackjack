Rails.application.routes.draw do
  get 'games/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :games, only: [:show]

  resources :users, only: [:index, :new, :create, :show]

  get '/login', to: 'sessions#new'

  post '/login', to: 'sessions#create'

  get '/', to: 'users#welcome', as: "welcome" 

  post '/make_bet', to: 'games#make_bet', as: 'make_bet'

  get '/deal', to: 'games#deal', as: 'deal'

  get'/game_board', to: 'games#game_board', as: 'game_board'

  get'/new_game_board', to: 'games#new_game_board', as: 'new_game_board'

  get '/hit', to: 'games#hit', as: 'hit'

  get '/stand', to: 'games#stand', as: 'stand'

  get '/bust', to: 'games#bust', as: 'bust'

  get '/win', to: 'games#win', as: 'win'

  get'/lose', to: 'games#lose', as: 'lose'

  get '/draw', to: 'games#draw', as: 'draw'

  get '/blackjack', to: 'games#blackjack', as: 'blackjack'
  
  get '/user/:id/funds', to: "users#add_funds", as: "add_funds"

  # get '/game_history', to: 'users#game_history', as: 'game_history'

  # get '/funds_history', to: 'users#funds_history', as: 'funds_history'

  get '/show_hand', to: 'games#show_hand' , as: "show_hand"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
