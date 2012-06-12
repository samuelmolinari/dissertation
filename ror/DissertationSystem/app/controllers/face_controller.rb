=begin

The face controller deals with all the actions related to a face.

@author Samuel Molinari
@version 06/05/2012

=end

require 'fileutils'
require 'RMagick'

class FaceController < ApplicationController
  
  # Get the face 
  before_filter :get_face, :except => [:train,:pre_training_upload]
  
  ##
  # Confirm the automatic recognition of a face
  def confirm_recognition
    
    # Current state of the action
    is_success = false
    
    message = ""
      
    # Get pending recognition linked to face
    pending_recognition = @face.pending_recognition
    
      
    # Only the user can confirm its own recognised face
    if !pending_recognition.nil? && @user.id == pending_recognition.user.id
      
      # Confirm the pending recognition
      pending_recognition.confirm
        
      # Action was a success
      success = true
        
      # Notice message
      message = "A face was confirmed as being yours"
      
    else
      
      # Notice message
      message = "You do not have the right to confirm this face"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Deny recognition of user
  def deny_recognition
    
    # Current state of the action
    is_success = false
    
    message = ""
    
    # Get pending recognition linked to face
    pending_recognition = @face.pending_recognition
      
    # Only the user can decline its own recognised face
    if !pending_recognition.nil? && @user.id == pending_recognition.user_id
      
      # Deny the pending recognition
      pending_recognition.deny
        
      # Action was a success
      success = true
        
      # Notice message
      message = "A face was denied as being yours"
      
    else
      
      # Notice message
      message = "You do not have the right to deny this face"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Tag an automatically detected face in a photo
  def tag_detection
    
    # Current state of the action
    success = false
    message = ""
    
    # Load the form data
    form_data = params[:tag]
      
    # Ignore following if the form doesn't exists
    if !form_data.nil?
      
      # Check if the user exists
      if User.exists?({ :id => form_data[:user_id] })
        
        user_id = form_data[:user_id].to_i
      
        # Add user to face
        @face.tag(user_id)
        
        # If the user tag its own face, don't create a notification, otherwise do
        if user_id != @user.id
          
          PendingRecognition.create({
            :face_id => @face.id,
            :user_id => @face.user_id
          })
          
        else
          
          # Delete prending recognition if the face was tag by the recognised user
          unless @face.pending_recognition.nil?
            
            @face.pending_recognition.destroy
            
          end
          
        end
        
          
        # Action was a success
        success = true
        
        # Notice message
        message = "Face was successfully tagged as #{User.find(form_data[:user_id]).fullname}"
      
      else
      
        # Notice Message
        message = "This user does not exist"
        
      end
      
    else
      
      # Notice Message
      message = "Something went wrong"

    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Remove tag from photo
  def remove_tag
    
    success = false
    message = ""
    
    # Only the owner of the photo, or the tagged person are allowed to remove the tag
    if @user.id == @face.photo.user_id || @user.id == @face.user_id
      
      # Remove tag
      @face.remove_tag
      
      # Action was a success
      success = true
      
      # Notice message
      message = "Tag was successfully removed"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Remove a face from a photo
  def remove
    
    # Current state of the action
    success = false
    
    message = ""
    
    # Only the owner of the photo can remove a face from a photo
    if @user.id == @face.photo.user_id
      
      # Remove face
      @face.destroy
      
      # Action was a success
      success = true
      
      # Notice message
      message = "Face was successfully removed from this photo"
      
    else
      
      # Notice Message
      message = "You do not have the right to remove this face"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Upload the photo used for the training
  def pre_training_upload
    
    # Get temporary file
    tmp = params["photo"].tempfile

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json =>  @user.train_new_face(tmp)  }
    end
    
  end
  
  ##
  # Train new face for the current user with a recently uploaded photo that generated temporary image file of faces
  def train
    
    # Current state of the action
    success = false
    
    message = ""
    
    # Check all the parameters are available, and add face
    if !params[:face].nil? && !params[:ref].nil? && @user.add_face(params[:ref],params[:face])
      
      # Action was a success
      success = true
      
      # Notice message
      message = "Face was successfully added to your set"
      
    else
      
      # Notice message
      message = "Face could not be added to your set"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Update privacy of a user
  def update_privacy_setting
    
    # Current state of the action
    success = false
    
    message = ""
    
    # Only the user who is tagged for that face can choose the privacy setting
    if @user.id == @face.user_id
      
      # Check all the parameters are available 
      if !params[:privacy_setting].nil? && !params[:privacy_setting][:cover].nil?
        
        # Update privacy settings
        @face.update_attributes({:cover_type => params[:privacy_setting][:cover]})
        
        # Action was a success
        success = true
        
        # Notice message
        message = "Privacy settings for this face were successfully updated"
        
      else
        
        # Notice message
        message = "Something went wrong"
        
      end
      
    else
      
      # Notice message
      message = "You do not have the right to change the privacy settings for this face"
      
    end
    
    flash[:notice] = message
    
    respond_to do |format|
      format.html { redirect_to :back}
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  private

  ##
  # Get face from ID
  def get_face
    
    @face = Face.find(params[:id]) unless params[:id].nil?
    
    # Only continue action if a face was associated with the request, otherwise, redirect user
    if @face.nil?
      
      message = "Something went wrong"
      
      # Notice message
      flash[:notice] = message
      
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json => { :success => false, :message => message } }
      end
      
    end
    
  end
  
end
