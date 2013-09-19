# == Schema Information
# Schema version: 20090423194502
#
# Table name: images
#
#  id           :integer         not null, primary key
#  parent_id    :integer
#  content_type :string(255)
#  filename     :string(255)
#  thumbnail    :string(255)
#  size         :integer
#  width        :integer
#  height       :integer
#  date_taken   :date
#  created_by   :integer
#  modified_by  :integer
#  project_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Image < ActiveRecord::Base
  include GenericSearch

  attr_accessor :collection
  attr_accessor :orig_width, :orig_height

  has_many :taxon_images, :class_name => "TaxonImage"

  has_many :image_joins, class_name: 'ImageJoin'
  has_many :objects, :through => :image_joins

  has_one :thumb, class_name: 'Image', foreign_key: 'parent_id'
  belongs_to :project
  has_attached_file :attachment, 
    :url => "/images/:id_partition/:style/:basename.:extension",
    :path => "public/images/:id_partition/:style/:basename.:extension",
    :thumb => "/images/:id_partition/thumb/:basename.:extension",
    :styles => { :thumb => "1000x60>"}
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

  def thumb
    self.attachment.styles[:thumb]
  end

  def public_filename(nothing = nil)
    self.attachment.url
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

  def thumb_width
    thumb.respond_to?(:width) ? thumb.width : 80
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
    @image_src ||= "#{directory}/original/#{attachment_file_name}?#{attachment_updated_at.to_json.gsub(/[A-Za-z:\-\s"]/, '')}"
  end

  def thumb_src
    @thumb_src ||= "#{directory}/thumb/#{attachment_file_name}?#{attachment_updated_at.to_json.gsub(/[A-Za-z:\-\s"]/, '')}"
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
#    "/images/#{id_with_zeroes[0,4]}/#{id_with_zeroes[4,4]}/"
    path = []
    (1000000000+id).to_s[1,9].scan(/\d{3}/) { |num| path.push(num) }
    "/images/#{path.join('/')}"
  end

  def id_with_zeroes
    "#{zeroes}#{id}"
  end
  
  def zeroes
    '00000000'[id.to_s.size..-1] # get zeroes complementary to id to make 8 digits
  end
end
