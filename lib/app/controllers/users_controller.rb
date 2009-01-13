class UsersController < ApplicationController
  before_filter :authorize, :except => [:new, :create, :forgot, :reset, :login, :logout]
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.username = params[:user][:username]
    if !@user.save then
      render :action => :new
    else
      flash[:notice] = "User created"
      session[:user_id] = @user.id
      redirect_to user_path(@user)
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if !@user.update_attributes(params[:user]) then
      render :action => :edit
    else
      flash[:notice] = "User updated"
      redirect_to user_path(@user)
    end
  end

  def forgot
    if request.post?
      # Note: temporary password needs an expiration date, and the existing password
      # should not be erased until the user logs in with the temporary password; this 
      # way if the user is being spoofed it will not affect their normal behavior.  If
      # the "real" password is used before the temporary password, it should also expire
      # the temporary password.
      if params[:username_or_email]
        user = User.find_by_username(params[:username_or_email])
        user ||= User.find_by_email(params[:username_or_email])
        
        if user
          user.set_password_key!
          UserMailer.deliver_forgot(user)
        end
        
        # Show this message even if it's an invalid request to prevent learning
        flash[:notice] = "Please check your email for instructions to proceed"
        redirect_to :action => :forgot
        return
      else
        flash.now[:notice] = "Please provide a username or email address"
      end
    end
  end

  def reset
    # Do not accept null key
    if params[:key]
      returning User.find_by_password_key(params[:key]) do |user|
        if user 
          if 24.hours.ago < user.password_key_created_at
            @reset_user = user
          else
            user.clear_password_key!
          end
        end
      end
    end
    if @reset_user.nil?
      flash[:notice] = "Request is not valid - perhaps it has expired?  Please try again."
      redirect_to forgot_password_path
      return
    end
    
    if request.put?
      if @reset_user.update_attributes(params[:user])
        flash[:notice] = 'Your password was successfully updated.'
        @reset_user.clear_password_key!
        session[:user_id] = @reset_user.id        
        redirect_to user_path(@reset_user)
      else
        # Did not type the same password twice or something
        render :action => 'reset'
      end
    end
  end

  def login
    if request.post?
      session[:user_id] = nil      
      user = User.authenticate(params[:username], params[:password])
      if user
        session[:user_id] = user.id
        user.clear_password_key!
        redirect_to user_path(user)
      else
        flash[:notice] = "Invalid username or password"
        redirect_to login_user_url
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    begin
      redirect_to :back
    rescue
      redirect_to login_user_url
    end
  end
  
  protected

  # Before filter  
  def authorize
    unless @current_user && (@current_user.id.to_s == params[:id] || @current_user.has_privilege?("edit_other_users"))
      head :not_found
    end
  end

end
