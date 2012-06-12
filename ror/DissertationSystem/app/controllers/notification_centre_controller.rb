=begin
	
Notification centre

@version 07/06/2012
@author Samuel Molinari
	
=end

class NotificationCentreController < ApplicationController
  
  ##
  # Retrieve the number of pending recognition for the logged in user
  def recognition
    respond_to do |format|
      format.js { render :json => @user.pending_recognitions.size }
    end
  end
  
end
