class UserConnection < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :follower, :class_name => "User", :foreign_key => "user_id"
  belongs_to :follow, :class_name => "User", :foreign_key => "connected_to_user_id"
  
end
