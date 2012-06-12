class AutoHideWhenWithUser < ActiveRecord::Base
  
  belongs_to  :auto_hide_from_user,
              :class_name => "AutoHideFromUser",
              :foreign_key => "auto_hide_from_user_id"
  
  belongs_to  :user,
              :class_name => "User",
              :foreign_key => "user_id"
  
end
