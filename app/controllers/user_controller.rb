require 'digest/sha1'

class UserController < ApplicationController
  include ApplicationHelper

  before_filter :protect, :only => :index

  def index
    @title = "RailsSpace User hub"
  end

  def register
    @title = "Register"
    if param_posted(:user)
      @user = User.new(params[:user])
      if @user.save
        @user.login!(session)
        flash[:notice] = "User #{@user.screen_name} created!"
        redirect_to_forwarding_url
      else
        @user.clear_password!
      end
    end
  end

  def login
    @title = "Log in to RailsSpace"
    if request.get?
      @user = User.new(:remember_me => cookies[:remember_me] || "0")
    else if param_posted(:user)
        @user = User.new(params[:user])
        user = User.find_by_screen_name_and_password(@user.screen_name, @user.password)
        if user
          user.login!(session)
          if @user.remember_me == "1"
            cookies[:remember_me] = { :value => "1", :expires => 10.days.from_now }
            user.authorization_token = Digest::SHA1.hexdigest("#{user.screen_name}:#{user.password}")
            user.save!
            cookies[:authorization_token] = { :value => user.authorization_token, :expires => 10.days.from_now }
          else
            cookies.delete(:remember_me)
            cookies.delete(:authorization_token)
          end
          flash[:notice] = "User #{@user.screen_name} logged in!"
          redirect_to_forwarding_url
        else
          #don't show the password in the view
          @user.clear_password!
          flash[:notice] = "Invalid screen name/password combination"
        end
      end
    end
  end
	
  def logout
    User.logout!(session, cookies)
    flash[:notice] = "Logged out"
    redirect_to :action => "index", :controller => "site"
  end

  private
	
  # Protect a page from unauthorized access
  def protect
    unless logged_in?
      session[:protected_page] = request.request_uri
      flash[:notice] = "Please log in first"
      redirect_to :action => "login"
      return false
    end
  end
	
  # returns true if a parameter corresponding to  the given symbol was posted
  def param_posted(symbol)
    request.post? and params[symbol]
  end
	
  # redirect to the previously requested url (if present)
  def redirect_to_forwarding_url
    if (redirect_url = session[:protected_page])
      session[:protected_page] = nil
      redirect_to redirect_url
    else
      redirect_to :action => "index"
    end
  end
end