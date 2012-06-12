class FaceHideFromUser < ActiveRecord::Base
  
  belongs_to  :face
  
  belongs_to  :hide_from_user,
              :class_name => "User",
              :foreign_key => "hide_from_user_id"
  
end
