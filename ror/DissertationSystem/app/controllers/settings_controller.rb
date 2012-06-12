=begin
  
  General settings controller
  
  @author Samuel Molinari
  @version 07/06/2012

=end

class SettingsController < ApplicationController
  
  ##
  # Update advanced cover settings (user specific)
  def auto_hide_from_user
    
    # Get list of user ids to be hidden from
    connections = params[:connections]

    # Get list of user ids the current user want to be hidden when found with them in the same photo
    with_connections = params[:with_connections]

    # Cover type
    cover_type = params[:cover_type].to_i unless params[:cover_type].nil?
    
    success = false
    
    message = "Something went wront"
    
    # If any parameters are missing, don't do anything
    if !connections.nil? && !with_connections.nil? && !cover_type.nil?
      
      # For each user to be hidden from
      connections.each do |key,val|
        
        # Get that user
        hide_from_user = User.find(val)
        
        # Continue if user exists
        unless hide_from_user.nil?
          
          # Find if a setting already exists with that user
          auto_hide_from_user = AutoHideFromUser.find(:first,:conditions => ["user_id = :user_id AND hide_from_user_id = :hide_from",{ :user_id => @user.id, :hide_from => hide_from_user.id }])
          
          # If a setting doesn't already exists
          if auto_hide_from_user.nil?
            
            # Create setting
            auto_hide_from_user = AutoHideFromUser.create({
              :user_id => @user.id,
              :hide_from_user_id => hide_from_user.id,
              :cover_type => cover_type
            })
          
          # If setting already exists, update it
          else
            
            auto_hide_from_user.update_attribute("cover_type",cover_type)
          
          end
          
          # Go through each user the current user doesn't want to be seen with
          with_connections.each do |key2,val2|
            
            # Get user id
            with_user_id = val2.to_i
            
            # Continue when the user id isn't 0 (not correct)
            unless with_user_id == 0
            
              # Continue if setting doesn't already exists
              if !auto_hide_from_user.when_with_users.exists?({ :user_id => with_user_id })
                
                AutoHideWhenWithUser.create({
                  :auto_hide_from_user_id => auto_hide_from_user.id,
                  :user_id => with_user_id
                })
                
              end
            
            # If user id is 0, then destroy all the settings "hide me when found in the same photo with those users"
            else
              
              auto_hide_from_user.when_with_users.each do |r|
                r.destroy
              end
              
            end

            success = true
            
            message = "Setting successfully updated"
          
          end
        
        end
        
      end
      
    end
    
    # Display message
    flash[:notice] = message
    
    # Send user to the previous page, or render a json formated file if the extension is JSON (AJAX call)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end
    
  end
  
  ##
  # Setting to hide from a certain group of people
  def global_auto_hide_from
    
    success = false
    message = ""

    # Setting to hide from a group of people
    group = params[:global_auto_hide][:group].to_i unless params[:global_auto_hide].nil?
    # Cover type
    cover_type = params[:global_auto_hide][:cover_type].to_i  unless params[:global_auto_hide].nil?
    
    # Continue if all parameters were parsed properly, and the picked group is a valid one
    if !group.nil? && !cover_type.nil? && User.auto_hide_exists?(group.to_i)
  
      # Update cover type
      @user.update_attribute(:auto_cover_type,cover_type)
      # Update group
      @user.update_attribute(:auto_hide_from,group)
      
      success = true
      
      message = "Setting successfully updated"
      
    else
      
      message = "Something went wrong"
      
    end
    
    # Display message
    flash[:notice] = message
    
    # Send user to the previous page, or render a json formated file if the extension is JSON (AJAX call)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :success => success, :message => message } }
    end

  end
  
end