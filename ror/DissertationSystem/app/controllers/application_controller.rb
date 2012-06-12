=begin
  
All other controller extends this controller

@author Samuel Molinari
@version 06/06/2012
  
=end

class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  # Methods to be run before any controller is loaded
  before_filter :init, :require_auth
  
  protected
  
  ##
  # Initialize controllers variables
  def init
    @user = get_user
  end
  
  ##
  # Every controllers require the viewer to be logged in (except when stated otherwise)
  def require_auth

    # When no user is logged in, redirect the visitor to the login page
    if @user.nil?
      respond_to do |format|
        format.html { redirect_to :controller => :auth, :action => :login }
      end
    end

  end
  
  private
  
  ##
  # Get user if it is logged in
  #
  # @return User nil means no user is logged in
  def get_user
    
    # Retrieve user id if stored in a cookies
    # @TODO Secure ID when stored in cookies
    if cookies[:user]
      return User.find(cookies[:user])

    # Retrieve user id if stored in session
    elsif session[:user]
      return User.find(session[:user])

    # No user logged in
    else
      return nil
    end

  end
  
end