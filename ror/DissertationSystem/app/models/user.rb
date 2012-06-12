require 'digest/sha2'
require 'securerandom'
require 'builder'
require 'csv'
require 'fileutils'
require 'RMagick'

class User < ActiveRecord::Base
  
  attr_accessor :password
  
  PRIVATE_LOCATION  = "#{Rails.root}/private/users/"
  TMP_PRIVATE_LOCATION = "#{Rails.root}/private/tmp/"
  TMP_PUBLIC_URL = "/images/tmp/"
  
  AUTO_HIDE_FROM = {
    :nobody                 => 0, # Nobody
    :public                 => 1, # Hide from people who are not connected to the user
    :people_not_in_photo    => 2, # Hide from everybody except other people tagged in the photo
    :everybody              => 3  # Any body (Connection + Public)
  }
  
  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i },
                    :confirmation => true

  validates :uname, :presence => true,
                    :uniqueness => true,
                    :format => { :with => /[0-9A-Za-z\-\._]+/ }

  validates :password,  :presence => true,
                        :length => {:minimum => 1}

  validates :email_confirmation, :fname, :lname, :dob, :presence => true

  has_many  :photos,
            :dependent => :destroy

  has_many  :albums,
            :dependent => :destroy

  has_many  :faces,
            :dependent => :destroy

  has_many  :pending_recognitions,
            :dependent => :destroy
            
  has_many  :detections,
            :through => :photos,
            :class_name => "Face",
            :foreign_key => "photo_id"
            
  has_many  :user_connections,
            :dependent => :destroy
            
  has_many  :connections,
            :class_name => "UserConnection",
            :foreign_key => "user_id",
            :dependent => :destroy
            
  has_many  :followers,
            :class_name => "UserConnection",
            :foreign_key => "connected_to_user_id",
            :dependent => :destroy
            
  has_many  :auto_hide_from_users,
            :dependent => :destroy
            
  has_many  :auto_hidden_from_users,
            :class_name => "AutoHideFromUser",
            :foreign_key => "hide_from_user_id",
            :dependent => :destroy
            
  has_many  :face_hidden_from_users,
            :class_name => "FaceHideFromUser",
            :foreign_key => "hide_from_user_id",
            :dependent => :destroy
            
            
  def self.auto_hide_exists?(i)
    
    exist = false
    
    AUTO_HIDE_FROM.each do |key,value|
      
      if value == i.to_i
        exist = true
        break
      end
      
    end
    
    return exist
    
  end
            
  ##
  # Check if the user follows another user
  # @params user:User
  # @return boolean
  def follows?(user)
    
    follow = false
    
    unless user.nil?
      follow = self.connections.exists?({ :connected_to_user_id => user.id })
    end
    
    return follow
    
  end
  
  ##
  # Make user follow another user
  # @params user:User
  def follow(user)
    
    unless user.nil?
      
      if !self.follows?(user)
        
        UserConnection.create({
          :user_id => self.id,
          :connected_to_user_id => user.id
        })
        
      end
      
    end
    
  end
  
  ##
  # Make user unfollow another user
  # @param user:User
  def unfollow(user)
    
    unless user.nil?
      
      if self.follows?(user)
        UserConnection.find_by_user_id_and_connected_to_user_id(self.id,user.id).destroy
      end
      
    end
    
  end
  
  
  ##
  # Generate the user's full name (firstname and lastname)
  #
  # @return String User's full name
  def full_name
    return "#{self.fname} #{self.lname}"
  end
  
  def password
    return @password
  end
  
  ##
  # Save plain password into hashed password
  #
  # @param pwd:String Password in plain text
  # @return 
  def password=(pwd)
    
    @password = pwd
    
    # Generate unique salt for this user
    self.salt_password = SecureRandom.hex(16)
    
    # Generate encrypted password
    self.hashed_password = User.encrypt_password(pwd,self.salt_password)
    
    # Save changes
    self.save
    
  end
  
  ##
  # Add face to improve user's face recognition
  # @param tmp_ref:String Temporary reference location of the temporary uploaded photo
  # @param tmp_id:Integer Temporary face's image ID
  # @return boolean
  def add_face(tmp_ref,tmp_id)
    
    begin
    
      # Load image
      img = Magick::ImageList.new(self.tmp_private_location+tmp_ref.to_s+"/"+tmp_id.to_s+".png")
    
      # Create face
      face = Face.create({
        :user_id => self.id,
      })
    
      # Create directory for the face if it doesn't already exist
      FileUtils.mkdir_p(face.dir)
    
      # Save image
      img.write(face.location)
      
      # Remove temporary folder
      FileUtils.remove_dir(self.tmp_private_location+tmp_ref.to_s+"/")
    
      return true
    
    rescue
      
      return false
      
    end
    
  end
  
  def fullname
    return self.full_name
  end
  
  def train_new_face(tmp_file)
   
    img = Magick::ImageList.new(File.absolute_path(tmp_file))
    orientation = img.orientation
    send = {"ref" => "","faces" => []} 

    if orientation == Magick::TopRightOrientation
      img.flop!
    elsif orientation == Magick::BottomRightOrientation
      img.rotate!(180)
    elsif orientation == Magick::BottomLeftOrientation
      img.flip!
    elsif orientation == Magick::LeftTopOrientation
      img.transpose!
    elsif orientation == Magick::RightTopOrientation
      img.rotate!(90)
    elsif orientation == Magick::RightBottomOrientation
      img.transverse!
    elsif orientation == Magick::LeftBottomOrientation
      img.rotate!(270)
    end
    
    img.orientation = Magick::TopLeftOrientation
    
    ref = SecureRandom.hex(20)
    
    send["ref"] = ref
    
    location = self.tmp_private_location+ref+"/"
    
    FileUtils.mkdir_p(location)
    
    newfilename = location+"original.png"
    
    img.write(newfilename)
    
    json = Face.detection(newfilename)
    
    unless json.nil?
        
      json["faces"].each_with_index do |f,index|
        wScale = img.columns/json["image"]["width"].to_f
        hScale = img.rows/json["image"]["height"].to_f
        face =  Magick::Image.constitute(
            f["width"]*wScale,
            f["height"]*hScale,
            "RGB",
            img.dispatch(
                f["x"]*wScale,
                f["y"]*hScale,
                f["width"]*wScale,
                f["height"]*hScale,
                'RGB'
            )
        )
        face.resize!(120,120)
        face.write(location+index.to_s+".png")
        
        send["faces"][index] = "#{self.tmp_access_control_url}?ref="+ref+"&file="+index.to_s+".png&width=60&height=60"
      end
      
    end
    
    return send.to_json
    
  end
  
  ##
  # Authenticate a user
  #
  # @param identifier:String Can be username or email
  # @param pwd:String Password in plain text
  # @return User nil if the authentication has failed
  def self.auth(identifier,pwd)
    
    # Initialize user
    user = nil
    
    # When a user exists with a username that matches the given identifier, retrieve it
    if(User.exists?(:uname => identifier))
      
      user = User.find_by_uname(identifier)
      
    # When a user exists with an email that matches the given identifier, retrive it
    elsif(User.exists?(:email => identifier))
      
      user = User.find_by_email(identifier)
      
    end
    
    # If the hashed password of the found user matches the newly encrypted using the user's salt, then the user is authenticated
    return user if !user.nil? && User.encrypt_password(pwd,user.salt_password) == user.hashed_password
    
    # Authentication has failed
    return nil
    
  end
  
  def generate_csv_db
    FileUtils.mkdir_p(self.private_location)
    csv = File.new(self.csv_db_location, "w")
    self.faces.each do |f|
      csv.puts("#{f.location};#{self.id}")
    end
    csv.close
    return self.csv_db_location
  end
  
  def get_csv_db_list
    list = []
    User.all.each do |u|
      list.push(u.generate_csv_db)
    end
    return list
  end
  
  def private_location
    return "#{PRIVATE_LOCATION}/#{self.id}/"
  end
  
  def tmp_private_location
    return "#{TMP_PRIVATE_LOCATION}/"
  end
  
  def tmp_access_control_url
    return "/image_administrator/tmp/"
  end
  
  def csv_db_location
    return "#{self.private_location}/db.csv"
  end

  
  private
  
  ##
  # Generate an encrypted password
  #
  # @param pwd:String Plain text password
  # @param salt:String Password salt
  # @return String Encrypted password
  def self.encrypt_password(pwd,salt)
    return Digest::SHA256.hexdigest(pwd+User.generate_salt(salt))
  end
  
  ##
  # Add extras to a salt locally (if someone can access the database, they wouldn't be able to decrypt the password)
  #
  # @param salt:String A salt
  # @return String Extended salt
  def self.generate_salt(salt)
    return "qNwaAGqFJIztqhYvbX6+98XwM3c=#{salt}/GRDn/1NZhbSZh+Q22kCYWxGde4="
  end
   
end
