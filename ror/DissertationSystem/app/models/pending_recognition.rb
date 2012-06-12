class PendingRecognition < ActiveRecord::Base
  belongs_to :face
  belongs_to :user
  
  ##
  # Confirm the recognition
  # @param user_id:Integer
  def confirm
    # Tag face
    self.face.tag(self.user_id)
    # Destroy pending recognition
    self.destroy
  end
  
  ##
  # Deny the recognition
  def deny
    # Destroy pending recogntion
    self.destroy
  end
  
end
