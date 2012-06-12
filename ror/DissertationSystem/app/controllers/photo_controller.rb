=begin

The photo controller deals with all the actions related to a photo.

@author Samuel Molinari
@version 17/04/2012

=end

class PhotoController < ApplicationController
  
  # Get photo
  before_filter :get_photo, :except => [:upload]
  
  ##
  # Remove a photo
  def remove
    
    # Current state of the action
    success = false
    
    # Only the owner of a photo can remove it
    if @is_owner
      
      # Remove photo
      @photo.destroy
      
      # Action was a success
      success = true
      
      # Notice message
      flash[:notice] = "Photo was successfully removed"
      
    else
      
      # Notice message
      flash[:notice] = "You do not have the right to remove this photo"
      
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => success }
    end
    
  end
  
  ##
  # Upload a photo
  def upload
    
    # Get temporay file
    tmp = params["imageuploader"].tempfile unless params[:imageuploader].nil?
    
    # File was correctly uploaded
    if !tmp.nil?
      
      # Create photo
      photo = Photo.create({
        :ref => Photo.generate_ref,
        :user_id => @user.id
      })
      
      # Run post-processing function new process (Makes the action finish now, user can move on)
      Thread.new({:photo => photo, :tmp => tmp}) { |param|
        
        ActiveRecord::Base.connection_pool.checkout
        
        photo = param[:photo]
        
        # Setup photo
        photo.process_image(param[:tmp])
        
        # Run detection and recognition
        photo.save_detection_and_recognition
        
        ActiveRecord::Base.connection_pool.checkin
        
        Thread.kill
        
      }
  
    end

    
    respond_to do |format|
      format.json { render :json => { :css => photo.css(:tiny), :ref => photo.ref } }
    end
    
  end
  
  ##
  # Report a photo
  def report
    
  end
  
  ##
  # Check if a resize version of a photo is ready
  def is_ready
    
    is_ready = false
    
    # Get the size to check on
    size = params[:size]
    
    # Get photo reference
    ref = params[:ref]
    
    # Get photo
    photo = Photo.find_by_ref(ref)
    
    # If the photo exists
    if !photo.nil?
      
      # Check if the file exists
      is_ready = File.exists?(photo.location(size))
      
    end
    
    respond_to do |format|
      format.json { render :json => is_ready } 
    end
    
  end
  
  private
  
  ##
  # Get photo from ref
  def get_photo
    
    @photo = Photo.find_by_ref(params[:ref]) unless params[:ref].nil?
    
    # Only continue action if a photo was associated with the request, otherwise, redirect user
    if @photo.nil?
      
      # Notice message
      flash[:notice] = "Something went wrong"
      
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json => false }
      end
      
    else
      
      # Check if the user is the owner of the photo
      @is_owner = @user.id == @photo.user_id
      
    end
    
  end
  
end
