class GamesController < ApplicationController
    before_action :check_deck, except: [:new_game_board]
  
    def new_game_board
  
      session[:turn] = 0
      session[:bet] = 0
      session[:dealer_hand] = [{remaining: 0}]
      session[:user_hand] = [{remaining: 0}]
      new_deck = RestClient.get('https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1')
      new_deck_parsed = JSON.parse(new_deck)
      session[:deck] = new_deck_parsed
      render :game_board
    end
  
    def game_board
      render :game_board
    end
  
    def make_bet
      if params[:bet].to_i <= 0 || @user.funds < params[:bet].to_i 
        flash[:notice] = "Sorry Insufficient Funds"
        session[:turn] = 0
        redirect_to game_board_path
      else 
        @game = Game.new
        session[:turn] += 1
        session[:bet] = params[:bet]
        session[:user_hand] = []
        user_hand1 = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
        user_hand2 = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
        session[:user_hand] << JSON.parse(user_hand1)
        session[:user_hand] << JSON.parse(user_hand2)
        session[:dealer_hand] = []
        dealer_hand1 = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
        dealer_hand2 = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
        session[:dealer_hand] << JSON.parse(dealer_hand1)
        session[:dealer_hand] << JSON.parse(dealer_hand2)  
       
        session[:user_value] = user_hand_value
        session[:dealer_value] = dealer_hand_value
        user_check_game
      end
    end
  
    def user_check_game
      if user_hand_value > 21
        flash[:user_bust] = "BUST!"
        @user.update(funds: @user.funds - session[:bet].to_i)
        Game.create(results: "Lose", user_id: @user.id)
        redirect_to bust_path
      elsif user_hand_value == 21 && session[:user_hand].count == 2
        flash[:blackjack] = "YOU GOT BLACKJACK!"
        @user.update(funds: @user.funds + blackjack_result)
        Game.create(results: "Win", user_id: @user.id)
        redirect_to blackjack_path
      else
        redirect_to game_board_path
      end
    end
  
  
    def hit
      user_hit = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
      session[:user_hand] << JSON.parse(user_hit)
      session[:user_value] = user_hand_value
      user_check_game
    end
  
    def show_hand
      if dealer_hand_value <= 16
        flash[:stand] = "STAND"
        redirect_to game_board_path
      else 
        redirect_to stand_path
      end
    end
  
    def stand
      if dealer_hand_value <= 16
        dealer_hit = RestClient.get("https://deckofcardsapi.com/api/deck/#{session[:deck]["deck_id"]}/draw/?count=1")
        session[:dealer_hand] << JSON.parse(dealer_hit)
        session[:dealer_value] = dealer_hand_value
        dealer_check
      elsif dealer_hand_value > 16
        dealer_check
      end
    end
  
  
    def dealer_check
      if dealer_hand_value > 21
        flash[:win] = "DEALER BUST!"
        @user.update(funds: @user.funds + session[:bet].to_i)
        Game.create(results: "Win", user_id: @user.id)
        redirect_to win_path
      elsif dealer_hand_value > 16 && dealer_hand_value <= 21
        end_of_game_check
      elsif dealer_hand_value <= 16
        flash[:stand] = "STAND"
        redirect_to game_board_path
      end
    end
  
    def end_of_game_check
      if dealer_hand_value < user_hand_value
        flash[:win] = "YOU WIN!"
        @user.update(funds: @user.funds + session[:bet].to_i)
        Game.create(results: "Win", user_id: @user.id)
        redirect_to win_path
      elsif dealer_hand_value > user_hand_value
        flash[:lose] = "YOU LOSE!"
        @user.update(funds: @user.funds - session[:bet].to_i)
        Game.create(results: "Lose", user_id: @user.id)
        redirect_to lose_path
      elsif dealer_hand_value == user_hand_value
        flash[:draw] = "DRAW!"
        Game.create(results: "Draw", user_id: @user.id)
        redirect_to draw_path
      end
    end
    
    def bust
      render :bust
    end
  
    def win
      render :win
    end
  
    def lose
      render :lose
    end
  
    def draw
      render :draw
    end
  
    def blackjack
      render :blackjack
    end
    
    
    
    def check_deck
      if deck_amount <= 1
        new_deck = RestClient.get('https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1')
        new_deck_parsed = JSON.parse(new_deck)
        session[:deck] = new_deck_parsed
      end
    end
    
    
    private
  
  def user_hand_value_string_array
    session[:user_hand].map do |card|
      card["cards"][0]["value"]
    end
  end
  
  def user_hand_value
      array = []
      user_hand_value_string_array.each do |string|
        if ["JACK", "QUEEN", "KING"].include?(string) 
          array << 10
        elsif %w(1 2 3 4 5 6 7 8 9 10).include?(string)
          array << string.to_i
        elsif string == "ACE"
          array << 11
        end
      end
      if array.include?(11) && array.sum > 21
        array.each do |value|
          if value == 11
            array.delete(value)
            array << 1
          end
        end
      end
      array.sum
    end
    
    def dealer_hand_value_string_array
      session[:dealer_hand].map do |card|
        card["cards"][0]["value"]
      end
    end
    
    def dealer_hand_value
      array = []
      dealer_hand_value_string_array.each do |string|
        if ["JACK", "QUEEN", "KING"].include?(string) 
          array << 10
        elsif %w(1 2 3 4 5 6 7 8 9 10).include?(string)
          array << string.to_i
        elsif string == "ACE"
          array << 11
        end
      end
      if array.sum > 21 && array.include?(11)
        array.each do |value|
          if value == 11
            array.delete(value)
            array << 1
          end
        end
      end
      array.sum
    end
    
    
    def blackjack_result
      session[:bet].to_i * 1.5
    end
    
    def deck_amount 
      # byebug
      dealer_deck = session[:dealer_hand].last["remaining"]
      user_deck = session[:user_hand].last["remaining"]
      if user_deck <= dealer_deck
        deck_amount = user_deck
      else
        deck_amount = dealer_deck
      end
      deck_amount
    end
  
  
  end
  
  