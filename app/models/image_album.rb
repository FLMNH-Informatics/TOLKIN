class ImageAlbum < ActiveRecord::Base
  include GenericSearch


  attr_accessor :collection
  attr_accessor :orig_width, :orig_height

  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "150x150>"}
  has_one :thumb, class_name: 'Image', foreign_key: 'parent_id'
  before_create :save_dimensions

  def self.inherited(subclass)
    subclass.class_eval do
      class << self
        def base_class
          self
        end
      end
    end
  end

  # DOESNT WORK WITHOUT ATTACHMENT_FU
  #  has_attachment :content_type => :image,
  #    :storage => :file_system,
  #    :max_size => 20.megabytes,
  #    :processor => :rmagick,
  #    :thumbnails => { :thumb => '1000x60' }
  #
  #  validates_as_attachment

  def save_dimensions
    self.width = Paperclip::Geometry.from_file(self.attachment.queued_for_write[:original]).width
    self.height = Paperclip::Geometry.from_file(self.attachment.queued_for_write[:original]).height
  end

  def photographer
    photographers_credits
  end

  def scale_to scale_width, scale_height
    scaled = self.clone
    scaled.orig_width  = self.width
    scaled.orig_height = self.height
    scaled.id = id
    scaled.collection = collection

    if(scaled.width <= scale_width && scaled.height <= scale_height)
      # do nothing
    elsif (scaled.width.to_f / scale_width) <= (scaled.height.to_f / scale_height)
      scale_ratio = (scaled.height.to_f / scale_height)
      scaled.height = scale_height
      scaled.width = (scaled.width.to_f / scale_ratio).floor
    else
      scale_ratio = (scaled.width.to_f / scale_width)
      scaled.height = (scaled.height.to_f / scale_ratio).floor
      scaled.width = scale_width
    end
    scaled
  end

  def attachment
    image
  end

  def photographers
    photographer_credits
  end

  def thumb_width
    image
    try(:width)
  end

  def thumb_height
    thumb.try(:height)
  end

  def thumb_filename
    thumb.try(:filename)
  end

  def place
    collection.index{ |item| item.id == self.id }+1
  end
  def image_src
    @image_src ||= "#{directory}/original/#{file_name}?#{updated_at.to_json.gsub(/[A-Za-z:\-\s"]/, '')}"
  end

  def thumb_src
    @thumb_src ||= "#{directory}/thumb/#{file_name}?#{updated_at.to_json.gsub(/[A-Za-z:\-\s"]/, '')}"
  end

  # use attachment_fu protected methods to remake thumbs
  def remake_thumbnails!
    self.thumbnails.each {|thumb| thumb.destroy }
    temp_file = create_temp_file rescue nil
    attachment_options[:thumbnails].each do |suffix, size|
      self.create_or_update_thumbnail(temp_file, suffix, *size) rescue nil
    end
  end

  private

  def directory
    "/system/images/#{id}/"
  end

  def id_with_zeroes
    "#{zeroes}#{id}"
  end

  def zeroes
    '00000000'[id.to_s.size..-1] # get zeroes complementary to id to make 8 digits
  end

end