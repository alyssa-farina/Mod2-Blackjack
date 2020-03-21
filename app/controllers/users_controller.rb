class UsersController < ApplicationController
    skip_before_action :authorized, only: [:new, :create, :show, :welcome]
    before_action :find_user, only: [:show]
  
    def welcome
    end
   
    def show
      @user = User.find(params[:id])
    end
   
    def index
    end
   
    def create
      @user = User.create(user_params)
      if @user.valid?
        flash[:notice] = "Signup successful! Welcome, #{@user.name}"
        session[:user_id] = @user.id
        redirect_to users_path(@user)
      else
        render :new
      end
    end
  
    def new
      @user = User.new
    end
   
    def game_history
    render :game_history
    end
  
    def games_played
      @user = User.games.count
      # maybe when the user clicks "get up from table" and/or "place bet and deal" it will save that as one game/hand
      #if game was won or game was lost save the game and count it as 1 played each time
    end
  
    def games_won
      result = "win"
      @user = User.games.count
      if result == "win"
        @user.games.count
      else
        @user.games
      end
    end
  
      
  #     if result == "win"
  #       games.result
  #   else 
  #   games.result
  # end
  
  
  
    def games_lost
      #calculates the number of games a user has lost
    end
    
    def add_funds
      @user = User.find(params[:id])
      if @user.funds 
          @user.funds += 200
          @user.save
      else
          @user.funds = 5
          @user.save
      end
      redirect_to user_path(@user)
  end
  
  def add_funds_one
    @user = User.find(params[:id])
    if @user.funds 
        @user.funds += 50
        @user.save
    else
        @user.funds = 5
        @user.save
    end
    redirect_to user_path(@user)
  end
  
  def user_funds
    if @user.funds < 50
      flash[:notice] = " It looks like you are running a little low on funds. Add some below"
       
        session[:user_id] = @user.id
        redirect_to user_path
    else
        redirect_to user_path
      
  end
  end
  
  
    def funds_history
      render :funds_history
    end
    
    def funds_gained
  
    #calculates the total amount of funds gained from playing the game 
      
    end
  
    def funds_lost
      #calculates the  amount the user has lost from every game combined
    end
  
  
    
    private
   
    def require_login
      return head(:forbidden) unless session.include? :user_id
    end
  
    def find_user
      @user = User.find(params[:id])
    end
  
    def user_params
      params.require(:user).permit(:name, :password ,:funds)
  
  end
  
  end
  
  