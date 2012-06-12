=begin

Any actions related with the user authentication

@author Samuel Molinari
@version 17/04/2012

=end

class AuthController < ApplicationController
  
  # This controller doesn't require a user to be logged in to be able to access it, only when trying to loging out
  before_filter :require_auth, :only => [:logout]
  
  ##
  # Login page
  def login
    
    if !@user.nil?
      respond_to do |format|
        format.html { redirect_to :controller => :home, :action => :index }
      end
    end
    
  end
  
  ##
  # Authenticate a visitor
  def authenticate
    
    # Authenticate user
    user = User.auth(params[:login][:identifier],params[:login][:password])
    
    # When a user has been authenticate with success
    if !user.nil?
      
      # Save user in cookie or a session depending if it wants to be remembered or not
      # @TODO Secure cookies
      if params[:login][:remember] == '1'
        cookies.permanent[:user] = user.id
      else
        session[:user] = user.id
      end
      

      respond_to do |format|
        # Redirect user to the photo manager page when authenticated or send it back to the URL of origin (if set)
        if params[:origin_url].nil? || params[:origin_url].blank?
          format.html { redirect_to :controller => :manage, :action => :index }
        else
          format.html { redirect_to params[:origin_url] }
        end
      end
      
    # Send user back to the login page when the authentication failed (user.nil?)
    else
      
      respond_to do |format|
        format.html { redirect_to :controller => :auth, :action => :login }
      end
      
    end
    
  end

  ##
  # Log user out
  def logout
    
    # Delete the session or cookies of that user trying to log out
    if !@user.nil?
      cookies.delete :user
      session.delete :user
    end

    # Redirect to the login page
    respond_to do |format|
      format.html { redirect_to :controller => :auth, :action => :login }
    end
    
  end

  ##
  # @TODO Send email
  def reset

  end
  
end
