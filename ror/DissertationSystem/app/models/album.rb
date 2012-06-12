class Album < ActiveRecord::Base
  
  has_many :photos
  
  validates :name, :length => {:minimum => 1}, :presence => true
  validates :user_id, :presence => true
  
end
