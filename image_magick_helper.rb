# frozen_string_literal: true

module ImageMagickHelper
  # Resizes an image to the specified width & height
  # Returns the file image name
  def self.resize_image(image_name, base_path, width = 1440, height = 400)
    image_name_no_ext = image_name.gsub('.jpg', '').gsub('.png', '').gsub('.gif', '').gsub('.jpeg', '').gsub('.JPG', '')
    final_image_name = "#{image_name_no_ext}-#{width}-#{height}.jpg"
    tmp_path = base_path

    system "convert #{base_path + image_name} -resize '#{width}x#{height}^' #{tmp_path + 'resized.png'}"
    system "convert #{tmp_path + 'resized.png'} -gravity center -crop '#{width}x#{height}+0+0' -auto-orient -quality 50 #{base_path + final_image_name}"

    return final_image_name
  end

  # Converts an image to grayscale
  def self.grayscale(image_name, base_path)
    extension = image_name.split('.').last
    image_name_no_ext = image_name.gsub('.jpg', '').gsub('.png', '').gsub('.gif', '').gsub('.jpeg', '').gsub('.JPG', '')
    final_image_name = "#{image_name_no_ext}-gray.#{extension}"

    system "convert #{base_path + image_name} -colorspace Gray -auto-orient #{base_path + final_image_name}"

    return final_image_name
  end
end
