class AutoHideFromUser < ActiveRecord::Base
  
  belongs_to  :user
  
  belongs_to  :hide_from_user,
              :class_name => "User",
              :foreign_key => "hide_from_user_id"
              
  has_many    :when_with_users,
              :class_name => "AutoHideWhenWithUser", 
              :foreign_key => "auto_hide_from_user_id",
              :dependent => :destroy
  
end
