require 'securerandom'
require 'fileutils'
require 'RMagick'
require 'json'

class Photo < ActiveRecord::Base
  
  PRIVATE_LOCATION  = "#{Rails.root}/private/images/"
  PUBLIC_LOCATION   = "#{Rails.root}/public/images/alt/"
  PUBLIC_URL        = "/images/alt/"

  SIZES = {
    :original => {
      :extension => "png",
      :name => "original"
    },
    :large => {
      :extension => "png",
      :name => "large",
      :size => 1024
    },
    :normal => {
      :extension => "png",
      :name => "normal",
      :size => 800
    },
    :medium => {
      :extension => "png",
      :name => "medium",
      :size => 640
    },
    :small => {
      :extension => "png",
      :name => "small",
      :size => 320
    },
    :thumbnail => {
      :extension => "png",
      :name => "thumbnail",
      :size => 180
    },
    :tiny => {
      :extension => "png",
      :name => "tiny",
      :size => 80
    }
  }
  
  validates :ref, :uniqueness => true, :presence => true
  validates :user_id, :presence => true
  
  belongs_to :user
  belongs_to :album
  has_many :faces, :dependent => :destroy
  has_many :detections, :class_name => :face, :foreign_key => :photo_id
  
  def save_detection_and_recognition
    
    json = Face.detection_and_recognition(self.location(:original),self.user.get_csv_db_list)
    
    unless json.nil?
      
      self.update_attributes({
        :detection_width => json["image"]["width"],
        :detection_height => json["image"]["height"]
      })
      
      json["faces"].each do |f|
        
        id = f["id"]
        error_margin = f["error_margin"]
        f.delete("id")
        f.delete("error_margin")

        f["photo_id"] = self.id
        face = Face.create(f)
        
        image = face.getImage()
        image.resize!(120,120)
        image.write(face.location)
        
        if(id > -1) 
          
          pending = PendingRecognition.create({
            :face_id => face.id,
            :user_id => id,
            :error_margin => error_margin
          })
          
        end
        
      end
      
    end
    
  end
  
  ##
  # Process the image (resize, give it the right orientation)
  def process_image(tmp_file)
  
    # Create directory to store images
    FileUtils.mkdir_p(self.private_location)
    
    # Move temporary file and rename it
    FileUtils.move(File.absolute_path(tmp_file),self.location(:original))
    
    # Load original image
    img = Magick::ImageList.new(self.location(:original))
    
    # Get image orientation
    orientation = img.orientation

    # Rotate image depending on its orientation so it can be displayed up-right
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
    
    # Change the orientation
    img.orientation = Magick::TopLeftOrientation
    
    # Go through all sizes
    SIZES.each { |k,v|
    
      # Create a name for the image to be saved
      name = v[:name]+"."+v[:extension]

      # Resize the image if a size is given (otherwise, keep the original size)
      if !v[:size].nil?
        
        img.change_geometry!("#{v[:size]}x>") { |cols, rows, img_copy|
          img_copy.resize!(cols, rows)
        }
        
      end
      
      # Save new image
      img.write(self.location(k))
      
    }
    
  end
  
  def public_location
    return "#{PUBLIC_LOCATION}/#{self.ref}/"
  end
  
  def private_location
    return "#{PRIVATE_LOCATION}/#{self.ref}/"
  end
  
  def public_url
    return "#{PUBLIC_URL}/#{self.ref}/"
  end
  
  def location(size)
    
    if size.nil?
      size = :normal
    end
    
    size = size.to_sym
    return "#{self.private_location}/#{SIZES[size][:name]}.#{SIZES[size][:extension]}"
  end
  
  def url(size)
    size = size.to_sym
    return "#{self.public_url}/#{SIZES[size][:name]}.#{SIZES[size][:extension]}"
  end
  
  def access_control_url(size)
    size = size.to_sym
    return "/image_administrator?ref=#{self.ref}&size=#{size}"
  end
  
  def css(size)
    size = size.to_sym
    base_size = [80,53]
    
    ratio = SIZES[size][:size]/base_size[0]
    height = base_size[1]*ratio
    
    return "background-image:url('#{self.access_control_url(size)}'); width:#{SIZES[size][:size]}px; height:#{height}px;"; 
  end
  
  def width
    img = Magick::ImageList.new(self.location(:original))
    return img.columns
  end
  
  def height
    img = Magick::ImageList.new(self.location(:original))
    return img.rows
  end
  
  def self.generate_ref
    
    ref = ""
    
    begin
      ref = SecureRandom.hex(20)
    end while Photo.exists?(:ref => ref)
    
    return ref
    
  end
  
end
