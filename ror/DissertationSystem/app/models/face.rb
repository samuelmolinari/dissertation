=begin

Face model

@author Samuel Molinari
@version 18/04/2012

=end

class Face < ActiveRecord::Base
  
  belongs_to :photo
  belongs_to :user
  
  has_one   :pending_recognition,
            :dependent => :destroy
            
  has_many  :face_hide_from_users,
            :dependent => :destroy
            
  has_many  :hidden_from_users,
            :class_name => "FaceHideFromUser",
            :foreign_key => "face_id"
  
  # Enumerate privacy setting options
  COVER = {
    :auto => 0,
    :rectangle => 1,
    :blur => 2,
    :pixelate => 3,
    :none => 4
  }
  
  # Path to the script use to run face detection and recognition
  DETECTOR_LOCATION = "../../Face Detection and Recognition/bin/final_script"
  
  ##
  # Run face detection and recognition
  # @param image_path:String path to the image
  # @param csv_dbs:String[] array of all the csv location use for the recognition
  # @return String JSON
  def self.detection_and_recognition(image_path,csv_dbs)
    
    # Run script and get output
    output = `#{DETECTOR_LOCATION} #{image_path} #{csv_dbs.join(" ")}`
    json = nil
    
    # If the output seems ok
    if !output.nil? && output != "failed"
      
      # Try parsing JSON string
      begin
        json = JSON.parse(output)
      rescue
        json = nil
      end
      
    end
    
    return json
    
  end
  
  ##
  # Run face detection
  # @param image_path:String path to the image
  # @return String JSON
  def self.detection(image_path)
    return Face.detection_and_recognition(image_path,[])
  end
  
  ##
  # Add tag to face
  # @param user_id:Integer
  def tag(user_id)
    self.user_id =  user_id
    self.save
  end
  
  ##
  # Remove tag from face
  def remove_tag
    self.user_id = nil
  end
  
  ##
  # Check if a face is tagged or not
  # @return boolean
  def has_tag?
    return !self.user_id.nil?
  end

  ##
  # Get image location
  # @return String
  def location
    return "#{self.dir}/#{self.id}.png"
  end
  
  ##
  # Get image directory
  # @return String
  def dir
    return "#{Rails.root}/private/faces/"
  end
  
  ##
  # Get the coordinates and size of a face depending on the image size
  # @param size:Symbol
  # @return Hash
  def get_face_coordinates(size)
    
    # Convert size to symbol
    size = size.to_sym
    
    # Initialize ratio value
    ratio = 1

    # Only deal with sizes smallers than the original width size
    if self.photo.width > Photo::SIZES[size][:size]
      
      # Compute new ratio
      ratio = self.compute_ratio(Photo::SIZES[size][:size])
      
    end
    
    return {:x => (self.x*ratio).round,:y => (self.y*ratio).round,:width => (self.width*ratio).round,:height => (self.height*ratio).round}
  
  end
  
  ##
  # Compute CSS for the face (to be used in views to generate tags over faces)
  # @param size:Symbol
  # @return String CSS
  def css(size)
    
    # Get size and coordinates matching the image size
    s = self.get_face_coordinates(size)
    
    return "top:#{s[:y]}px;left:#{s[:x]}px;width:#{s[:width]}px;height:#{s[:height]}px;position:absolute;"
    
  end
  
  ##
  # Crop the original photo the face belongs to, crop the face out, and save it to its location
  def crop_for_recognition
    
    # Load image
    img = Magick::ImageList.new(self.photo.location(:original))
    
    # Compute ratios
    ratio = self.compute_ratio(img.columns)
    
    # Crop image
    face =  Magick::Image.constitute(
        self.width*ratio,
        self.height*ratio,
        "RGB",
        img.dispatch(
            self.x*ratio,
            self.y*ratio,
            self.width*ratio,
            self.height*ratio,
            'RGB'
        )
    )
    
    # Resize to the size used for recognition
    face.resize!(120,120)
    
    # Save image
    face.write(self.location)
    
  end
  
  ##
  # Apply privacy settings on the photo the face belongs to
  def cover_face(img,viewer)
    
    cover = self.get_cover_for_viewer(viewer)
    
    # Cover face with a plain rectangle
    if cover == COVER[:rectangle]
      
      self.rectangle_cover(img)
    
    # Blur face out
    elsif cover == COVER[:blur]
      
      self.blur_cover(img)
      
    # Pixelate face
    elsif cover == COVER[:pixelate]
      
      self.pixelate_cover(img)
      
    end

  end
  
  ##
  # Cover face with a plain black rectangle
  # @param img:Magick::Image
  def rectangle_cover(img)
    
    # Compute ratio
    ratio = self.compute_ratio(img.columns)
    
    # Create canvas
    rectangle = Magick::Draw.new
    
    # Set filling to opaque
    rectangle.fill_opacity(1)
    
    # Create rectangle
    rectangle.rectangle(self.x*ratio,self.y*ratio,(self.x+self.width)*ratio,(self.y+self.height)*ratio)
    
    # Draw rectangle on image
    rectangle.draw(img)
    
  end
  
  ##
  # Blur face out
  # @param img:Magick::Image
  def blur_cover(img)
  
    mask = Magick::Image.new(img.columns,img.rows)
    blur = img.copy
    canvas = Magick::Draw.new
    canvas.fill_opacity(1)
    canvas.fill('black')
    canvas.rectangle(0,0,img.columns,img.rows)
    canvas.fill('white')
      
    # Compute ratio
    ratio = self.compute_ratio(img.columns)
    
    # Compute the area the blur is covering, slighly extend it
    height  = self.height*ratio #+(self.height*ratio/1.9)
    width   = self.width*ratio #+(self.width*ratio/4)
    y       = self.y*ratio #-(self.height*ratio/3)
    x       = self.x*ratio #-(self.width*ratio/9)
    
    canvas.circle(x+width/2,y+height/2,x-width/8,y-height/8)
    
    x -= width/2
    y -= height/2
    width *= 2
    height *= 2
    
    # Crop face out
    face =  Magick::Image.constitute(
        width,
        height,
        "RGB",
        blur.dispatch(
            x,
            y,
            width,
            height,
            'RGB'
        )
    )
    
    # Apply blur to the face
    face = face.gaussian_blur(width*0.12,width*0.12)
   
    # Cover original face with the recently blured face
    blur.composite!(
        face,
        x,
        y,
        Magick::OverCompositeOp
    )
    
    canvas.draw(mask)
    mask = mask.blur_image(width*0.05,width*0.05)
    
    mask.matte = false
    blur.matte = true
    blur = blur.composite(mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)
    
    img.composite!(blur, 0, 0, Magick::OverCompositeOp)
    
  end
  
  ##
  # Pixelate face
  # @param img:Magick::Image
  def pixelate_cover(img)
    
    # Compute ratio
    ratio = self.compute_ratio(img.columns)
    
    # Compute new height and y position
    height = self.height*ratio+(self.height*ratio/1.9)
    y = self.y*ratio-(self.height*ratio/3)
    
    # Crop face out
    face =  Magick::Image.constitute(
        self.width*ratio,
        height,
        "RGB",
        img.dispatch(
            self.x*ratio,
            y,
            self.width*ratio,
            height,
            'RGB'
        )
    )
    
    # Number of pixels on x axis
    num_pixels = 6
    
    if self.width*ratio < num_pixels*3
    
      # Reduce face's size
      face = face.resize(1/(self.width*ratio/4))
      
    else
      
      # Reduce face's size
      face = face.resize(1/((self.width*ratio)/num_pixels))
      
    end
    
    # Resize face to its original size, without any blurring filter
    face = face.resize(self.width*ratio,height,Magick::LanczosFilter,0)
   
    # Cover original face with the recently pixelated face
    img.composite!(
        face,
        self.x*ratio,
        y,
        Magick::OverCompositeOp
    )
    
  end
  
  ##
  # Check if the face is concidered as anonymous to a given user
  # @param viewer:User
  # @return boolean
  def get_cover_for_viewer(viewer)

      return COVER[:none] if viewer.id == self.user_id || viewer.id == self.photo.user_id || (self.user.nil? && !self.pending_recognition.nil? && self.pending_recognition.user_id == viewer.id) || (self.user.nil? && self.pending_recognition.nil?)
      
      user = nil
      
      if self.user.nil?
        user = self.pending_recognition.user
      else
        user = self.user
      end
      
      # If the face hasn't a cover type assigned to it
      if self.cover_type.nil? || self.cover_type == Face::COVER[:auto]
        
        # Find the record that show the user want that face to be hidden from the viewer
        face_specifically_hidden_from_user = self.hidden_from_users.find(:first,:conditions => ["hide_from_user_id = :user_id",{:user_id => viewer.id}])
        
        # If the user doesn't want this face be automatically hidden from this suer
        if face_specifically_hidden_from_user.nil?
          
          # Find the record that show the user wants to be hidden automatically from the viewer
          user_specifically_hidden_from_user = user.auto_hide_from_users.find(:first,:conditions => ["hide_from_user_id = :user_id",{:user_id => viewer.id}])
          
          # If the user doesn't want to be automatically hidden from the viewer
          if user_specifically_hidden_from_user.nil?
            
            cover = user.auto_cover_type

            if !cover.nil? && cover != Face::COVER[:none]
              
              group = user.auto_hide_from
              
              if group == User::AUTO_HIDE_FROM[:everybody]
                
                return cover
                
              elsif group == User::AUTO_HIDE_FROM[:public] && !user.connections.exists?({ :connected_to_user_id => viewer.id })
                
                return cover
                
              elsif group == User::AUTO_HIDE_FROM[:people_not_in_photo] && !self.photo.faces.exists?({ :user_id => viewer.id })
                
                self.photo.faces.each do |f|
                  unless f.pending_recognition.nil?
                    return COVER[:none] if f.pending_recognition.user_id == viewer.id 
                  end
                end
                
                return cover
                
              else
                
                return COVER[:none]
                
              end
              
            else
              
              return COVER[:none]
              
            end
            
          else
            
            ids = []
            
            self.photo.faces.each do |f|
              
              if f.user_id.nil?
                ids.push(f.pending_recognition.user_id) if !f.pending_recognition.nil?
              else
                ids.push(f.user_id)
              end
              
            end
            
            if user_specifically_hidden_from_user.when_with_users.empty? || user_specifically_hidden_from_user.when_with_users.exists?({ :user_id => ids })
            
              return user_specifically_hidden_from_user.cover_type
              
            else
              
              return COVER[:none]
              
            end
            
          end
          
        else
          
          return face_specifically_hidden_from_user.cover_type
          
        end
        
      else
        
        return self.cover_type
        
      end
    
  end
  
  ##
  # Check if the face is concidered as anonymous to a given user
  # @param viewer:User
  # @return boolean
  def is_anonymous?(viewer)
    return self.get_cover_for_viewer(viewer) != COVER[:none]
  end
  
  ##
  # URL to be used in any views to display the face
  # @param width:Integer
  # @param height:Integer
  # @return String
  def access_control_url(width,height)
    
    # Initialize size parameters
    size = ""
    
    # If size options are presents, create a parameters string to put into the URL
    if(!width.nil? && !height.nil?)
      size = "&width=#{width.to_s}&height=#{height.to_s}"
    end
    
    return "/image_administrator/face?id=#{self.id}"+size
    
  end
  
  ##
  # Load the face image
  # @return Magick::Image
  def getImage()
    image = Magick::ImageList.new(self.photo.location(:original))
    ratio = self.compute_ratio(image.columns)
    
    image.crop!(
        self.x*ratio,
        self.y*ratio,
        self.width*ratio,
        self.height*ratio)
    return image;
    
  end
  
  ##
  # Get the default anonymous image when a user is hidden from the viewer
  # @return String
  def self.anonymous_location
    return "#{Rails.root}/private/faces/anonymous.png"
  end
  
  ##
  # Compute ratio of the photo with and the one when the detection occured
  # @return Double
  def compute_ratio(image_width)
    return image_width.to_f/self.photo.detection_width.to_f
  end
  
end
