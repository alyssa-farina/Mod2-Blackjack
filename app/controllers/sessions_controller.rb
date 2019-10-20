class SessionsController < ApplicationController
    skip_before_action :authorized, only: [:new, :create]
  
    def new
      render :new
    end
  
    def create
      
      @user = User.find_by({ name: params[:name] })
  
     
      if !!@user && @user.authenticate(params[:password])
        flash[:notice] = "Successfully logged in #{@user.name}!"
       
        session[:user_id] = @user.id
        redirect_to users_path
      else
        flash[:notice] = "Invalid name or password"
        redirect_to login_path
      end
  
    end
  
  end
  
  