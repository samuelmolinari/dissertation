=begin

Controller related to the account management

@version 06/06/2012
@author Samuel Molinari

=end

require 'fileutils'
require 'RMagick'

class AccountController < ApplicationController
  
  # No need of authentification when creating an account
  before_filter :require_auth, :except => [:create]
  
  ##
  # Create an account/user
  def create

    # Init. new user
    @user = User.new
    
    # Only create when it's a post request
    if request.post?
      
      # Init. new user with posted parameters
      @user = User.new(params[:user])
      
      # Save new user
      if @user.save
        
        # Create session for the new user
        session[:user] = @user.id
        
        # Redirect to the photo management page
        respond_to do |format|
          format.html { redirect_to :controller => :manage, :action => :index }
        end
        
      end
      
    end
    
  end

  ##
  # Delete account/user
  def delete

    # Delete the session or cookies of that user trying to log out
    if !@user.nil?
      cookies.delete :user
      session.delete :user
    end

    # Destroy user
    @user.destroy

  end

  ##
  # User profile page
  def profile
    
    # If it's a post request, update user profile/attributes
    if request.post?
      
      @user.update_attributes(params[:user])
      
    end
    
  end
  
  ##
  # Allow user to build its own face profile for the face recognition
  def train_new_face

    # Temp reference number and face id must be given for the training to take place
    if params[:ref] && params[:face]

      # Load face image
      img = Magick::ImageList.new(@user.tmp_private_location+"#{params[:ref]}/#{params[:file]}")

      # Create new face in DB
      face = Face.create({
        :user_id => @user.id,
      })

      # Create directory for the face to be stored if it doesn't already exists
      FileUtils.mkdir_p(face.dir)

      # Copy the face image to that location
      img.write(face.location)

      # Remove temporary dir
      FileUtils.remove_dir(@user.tmp_private_location+params[:ref]+"/")

    end
    
    # Redirect to the previous page
    respond_to do |format|
      format.html { redirect_to :back }
    end
    
  end
end
