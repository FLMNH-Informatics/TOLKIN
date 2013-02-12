class Chromosome::ZFile < ActiveRecord::Base

  include GenericSearch

  has_many :zfile_images, class_name: 'ImageJoin', as: :object
  has_many :zimages, :through => :zfile_images, :source => :image

  has_many :hybridizations

  #has_and_belongs_to_many :chr_images, :join_table => "zfiles_images"
  #has_and_belongs_to_many :images, :join_table => "zfiles_images", :association_foreign_key => "chr_image_id", :class_name => "ChrImage"

  has_and_belongs_to_many :probes,  :class_name => 'Chromosome::Probe', :join_table => "probes_zfiles", :uniq => true, :foreign_key => "z_file_id"

  belongs_to :user

  has_attached_file :zvi
  
  cattr_reader :per_page
  @@per_page = 10

  scope :for_project, lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

  def personnel
    self.user
  end

  def zvi_file
    self.zvi
  end

  private
  def self.searchable_columns
    @searchable_columns  ||= get_searchable_columns
  end

  def self.get_searchable_columns
    search_columns =  [
        { column: "zvi_file_name", label: "ZVI filename" },
        { column: "caption"}
    ].inject([])  do | filters ,column|
      col_name = column[:column]
      col_info = columns_hash[col_name]
      throw "#{col_name} not found in sequence" unless col_info
      col_hash = {"name" => col_name, "type" => col_info.type.to_s }
      if column[:label]
          col_hash['label'] = column[:label]
        else
          col_hash['label'] = column[:column].humanize
        end
        filters << col_hash
        #add active select for filters that display on page load
        if column[:active]
          col_hash['active'] = column[:active]
        else
          col_hash['active'] = false
        end
        filters << col_hash
    end
  end
end