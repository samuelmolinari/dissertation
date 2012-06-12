=begin
  
@version 07/06/2012
@author Samuel Molinari
  
=end

class UserController < ApplicationController
  
  
  before_filter :get_user_from_uname
  
  def index
    render :action => :profile
  end
  
  def photos
    @photos = Photo.find_all_by_user_id(@viewing_user.id)
  end

  def photo
    @photo = Photo.find_by_ref(params[:ref])
    @is_owner = @photo.user.id == @user.id
    @faces = @photo.faces
    @image_url = @photo.access_control_url(:medium)
    @user_face = @faces.where({:user_id => @user.id})
    @user_in_photo = !@user_face.nil? && !@user_face.blank?
    @unknown_faces_excluding_user = @faces.find(:all,:conditions => ["user_id IS NULL",{:user => @user.id}])
    @known_faces_excluding_user = @faces.find(:all,:conditions => ["user_id <> :user AND user_id IS NOT NULL",{:user => @user.id}])
  end
  
  def profile
    
  end
  
  def follow
    
    success = false
    user = User.find(params[:id])
    
    unless user.nil?
      
      @user.follow(user)
      
      success = true
      
      flash[:notice] = "You are now following #{user.fullname}"
      
    else
      
      flash[:notice] = "This user doesn't exists"
      
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => success }
    end
    
  end
  
  def unfollow
    
    success = false
    user = User.find(params[:id])
    
    unless user.nil?
      
      @user.unfollow(user)
      success = true
      
      flash[:notice] = "You have stopped following #{user.fullname}"
      
    else
      
      flash[:notice] = "This user doesn't exists"
      
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => success }
    end
    
  end
  
  private
  
  def get_user_from_uname
    @viewing_user = User.find_by_uname(params[:uname])
  end
  
end
