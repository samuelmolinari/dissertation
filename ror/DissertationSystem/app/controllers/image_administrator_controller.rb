=begin

Load images dynamically to hide users faces when needed

@author Samuel Molinari
@version 06/06/2012
 
=end

require 'RMagick'

class ImageAdministratorController < ApplicationController
  
  ##
  # Load image from that view
  def index

    # Get photo to be loaded
    photo = Photo.find_by_ref(params[:ref])

    # Fobid displaying the original image size
    if params[:size] != "original"

      # Load image with the specified size
      image = Magick::ImageList.new(photo.location(params[:size]))
      
      # If the user isn't the owner of this photo, cover faces if needed
      if photo.user.id != @user.id
        # Go through each faces found in the photo
        photo.faces.each do |f|
          # If the face has no specified user or the face doesn't belong to the user viewing it, then try to cover it
          if f.user.nil? || f.user.id != @user.id
            f.cover_face(image,@user)
          end
        end
      end
      
      # Send the image data
      send_data image.to_blob, :type => image.mime_type, :disposition => 'inline'

    end

  end
  
  ##
  # Load faces from that view
  def face

    # Get face to be rendered
    face = Face.find(params[:id])

    # Get the size of the desired face to be rendered
    width = params[:width]
    height = params[:height]
    image = nil
    
    # The face should be hidden if the settings of that face implies it should be hidden from the viewer, otherwise, load the normal face
    if !face.is_anonymous?(@user)
      image = Magick::ImageList.new(face.location)
    else
      image = Magick::ImageList.new(Face.anonymous_location)
    end
    
    # Resize the image to the desired size if a width AND height were given
    if(!width.nil? && !height.nil?)
      image.resize!(width.to_i,height.to_i);
    end
    
    # Send the image data
    send_data image.to_blob, :type => image.mime_type, :disposition => 'inline'

  end
  
  ##
  # Display temporary faces when user upload a photo to train its eigenface
  def tmp

    # Load face
    image = Magick::ImageList.new(@user.tmp_private_location+"#{params[:ref]}/#{params[:file]}")
    
    # Resize the image to the desired size if a width AND height were given
    if(!params[:width].nil? && !params[:height].nil?)
      image.resize!(params[:width].to_i,params[:height].to_i)
    end

    # Send the image data
    send_data image.to_blob, :type => image.mime_type, :disposition => 'inline'
    
  end
  
end
