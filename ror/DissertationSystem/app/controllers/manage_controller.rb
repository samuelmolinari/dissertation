=begin

Photo manager's controller  

@version 06/06/2012
@author Samuel Molinari
  
=end

require 'fileutils'
require 'RMagick'

class ManageController < ApplicationController

  ##
  # Index page
  def index
  end
  
  ##
  # Label face
  def tag

    # Get user ID
    id = params[:tag][:id]

    # Targeted detected face
    face = Face.find(params[:face])

    # Get the pending recognition for that face
    pending = face.pending_recognition
    
    # Label face with the given user id
    face.update_attributes({:user_id => id})
    
    # Delete pending recognition if the user that received the notification is the one that have been tagging the face
    if !pending.nil? && pending.user.id == @user.id
      pending.destroy
    end
    
    # Create a notification if the user that has tagged the face isn't the one being tagged, and that the face has no pending recognition
    if id.to_i != @user.id && face.pending_recognition.nil?
      PendingRecognition.create({
        :face_id => face.id,
        :user_id => id
      })
    end
    
    # Redirect user to the previous page
    respond_to do |format|
      format.html { redirect_to :back }
    end

  end
  
  ##
  # List all the pending recognitions for the current logged in user
  def recognitions
    @recognitions = @user.pending_recognitions
    @is_empty = @recognitions.empty?
  end
  
  ##
  # Update face cover option for a specific face
  def face_cover

    # Get targetted face
    face = Face.find_by_id_and_user_id(params[:id],@user.id)

    # Update cover
    face.update_attributes({:cover_type => params[:privacy_setting][:cover]})
    
    # Redirect user to the previous page
    respond_to do |format|
      format.html { redirect_to :back}
    end

  end
  
  ##
  # Remove face
  def remove_face

    # Targeted face
    face = Face.find(params[:id])
    
    # If the one trying to delete the face is the owner of the photo, then remove the face
    if face.photo.user.id == @user.id
      FileUtils.remove(face.location)
      face.destroy
    end
    
    # Redirect user to the previous page
    respond_to do |format|
      format.html { redirect_to :back }
    end
    
  end
  
  ##
  # Confirm pending recognition
  def confirm_pending_recognition

    # Get the targeted pending recognition
    pr = PendingRecognition.find(params[:id])

    # Check if the confirmation is "true", if not it's false
    ok = params[:confirm] == "true"
    
    # Continue if the pending recognition is targeted to the current logged in user, or the recognised face is labled as the current user
    if pr.user.id == @user.id || pr.face.user.id == @user.id

      # User confirms this face is his/hers
      if(ok)
        face = pr.face
        face.update_attributes({:user_id => pr.user.id})
        face.crop_for_recognition
        pr.destroy

      # User denies recognition
      else
        pr.face.update_attributes({:user_id => nil})
        pr.destroy
      end

    end

    # Redirect user to the previous page
    respond_to do |format|
      format.html {redirect_to :back}
    end

  end
  
  ##
  # Users' name autocomplete
  def autocomplete_user
    
    conditions = ""
    map = {}
    
    # Build SQL query, with only 1 word
    if(params[:name].split(" ").size == 1)

      # Name key mapped to the given string with spaces removed
      map = {:name => "%#{params[:name].gsub(" ","")}%"}
      conditions = "fname LIKE :name OR lname LIKE :name"

    # More than 1 word string
    else
      
      # Go through each words
      params[:name].split(" ").each_with_index do |word,index|
        
        # Remove any extra spaces
        word.gsub!(" ","")
        
        # If the string is empty after removing all spaces, then ignore
        if(!word.empty?) 

          # Create key for that word
          key = "word#{index}"

          # Map word with SQL wild cards to the key 
          map[key.to_sym] = "%#{word}%"
          
          # If it's the first condition to be added
          if(index == 0 || conditions.gsub(" ","").empty?)
            conditions = "(fname LIKE :#{key} OR lname LIKE :#{key})"

          # Concatinate condition to the previous one
          else
            conditions += " AND (fname LIKE :#{key} OR lname LIKE :#{key})"
          end
          
        end
        
      end
      
    end
    
    # Find all user with the previously built conditions
    users = User.find(:all,:select => [:id,:fname,:lname,:uname],:conditions => [conditions,map],:limit => 10)
    
    # Redirect user to the previous page
    respond_to do |format|
      format.js { render :json => users }
    end
    
  end
  
end
