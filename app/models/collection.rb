class Collection < ActiveRecord::Base

  include GenericSearch
  include Models::Mixins::ScopeLimitable

  belongs_to :project
  belongs_to :user
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id', primary_key: :user_id
  belongs_to :recpermission
  #annotations are not stored as strings
  has_many :annotations
  has_many :collections_images, class_name: 'ImageJoin', as: :object
  has_many :images, through: :collections_images
  belongs_to  :elevation_unit,
    :class_name => "LengthUnit",
    :foreign_key => "elevation_unit_id"
  belongs_to :iso_country, :class_name => "IsoCountry", :foreign_key => "iso_country_code"
  belongs_to  :recpermission,
    :class_name => "Recpermission",
    :foreign_key => "recpermission_id"

  belongs_to  :taxon

  belongs_to :taxon_minimal, class_name: 'Taxon', foreign_key: 'taxon_id', select: 'id, name, author, infra_author, publication, volume_num, pages, publication_date'
  #belongs_to  :updated_by, :class_name => "User", :foreign_key => "last_updated_by"
  belongs_to :updater, :class_name => "User", :foreign_key => "last_updated_by", primary_key: :user_id

  scope :for_project, lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

  scope :taxon_name,  lambda { |value| {
#      include: 'taxon',
      conditions: [ 'taxa.name ilike ?', "%#{value}%" ]
  }}

  composite :label, [
    :collector,
    :collection_number
  ]
  def label
    [collector, collection_number].compact.join(' ')
  end

#  searchable  :collector,
#              :collection_number,
#              :country,
#              :county,
#              :herbarium,
#              :island,
#              :label_text,
#              :desc,
#              :notes,
#              { association: :taxon, attribute: :name },
#              :locality

  def display_attr_val     # a reader
    return (self.collector.to_s+" "+self.collection_number.to_s)
  end

#  def self.create_copy id
#    @new =  Collection.find(id).clone
#  end

  validates_presence_of :collector, :project_id, :user_id, :message => "missing required field"
  #validates_numericality_of :accession_num, :barcode,:allow_nil=>true, :message=> "Field is Not Number"#, :accession_num, :barcode, :accuracy # dont know y but doesnt seem to work with inplace editor so temp commented, ChrisG - why oh why oh why? not consistent with data
  validates_numericality_of :accuracy, :message => "Field is Not Number", :allow_nil=>true

#  def creator_id
#    user_id
#  end

  def self.save_search(options, project, current_user, tag_name)
    AdvancedSearch.transaction do
      debugger
      saved_search =  AdvancedSearch.create(:params => options.to_json,
        :model => "collection",
        :creator => current_user,
        :project => project
      )
      tag = Tag.find_or_create_by_name(tag_name)
      tag.taggings.create!(:user => current_user, :tag => tag, :taggable_id => saved_search.id, :taggable_type => saved_search.class.to_s)
      saved_search
    end
  end

  select_scope :start_date, {
    select: [ :coll_start_date ]
  }
  def start_date
    coll_start_date
  end

  def name
    "#{collector} #{collection_number}"
  end

  def editable?
    recpermission.name.upcase == Recpermission.edit.upcase
  end

  def deletable?
    recpermission.name.upcase == Recpermission.delete.upcase
  end

  def can_edit?(userid)
    current_user = User.find(userid, bypass_auth: true)

    # grant edit permissions if
    # - current user is administrator
    # - current user is project manager
    # - record is marked as editable and current user is an updater
    # - current user is owner and has at least updater permissions
    current_user.is_admin? || current_user.is_manager?(project_id) ||
      ((editable? || deletable?) && current_user.is_updater?(project_id)) ||
      (user_id == userid && current_user.is_updater?(project_id))
  end

  def canedit?(userid)
    self.can_edit?(userid)
  end

  def candelete?(userid)
    deletable? || user_id == userid
  end
  
  def label
    [collector, collection_number].compact.join(' ')
  end

  def to_s
    label
  end

 class << self
   private
   def searchable_columns
     columns_searchable = columns
     columns_searchable.unshift(columns_searchable.delete(columns_searchable.find{|c| c.name=="taxon_id"})) #Shifting taxon to be the first item in the array (as requested by euphorbia people on 06/22/2010) -rajat sehgal
   end
 end
 def self.searchable_columns
   @searchable_columns ||= [ 
     'taxon',
     'collector',
     'associate_collectors',
     'collection_number',
     'coll_start_date',
     'country',
     'state_province',
     'county',
     'island',
     'vegetation',
     'geology',
     'notes',
     'elevation_start',
     'elevation_end',
     'locality',
     'institution_code',
     'plant_description',
     'type_name',
     'type_status',
     'barcode',
     'accession_num',
     'fruiting',
     'flowering',
     'silica_sample'
   ].collect { |col_name|
     column = columns_hash[col_name] || columns_hash["#{col_name}_id"]
     {"name" => column.name, "type" => column.type.to_s }
   }
 end

#      def self.searchable_columns
#        @searchable_columns  ||= get_searchable_columns
#      end

#    def self.get_searchable_columns
#      search_columns =  [ "collector",  "collection_number", "country", "county", "herbarium", "island", "label_text", "desc", "notes", "taxon_id", "locality" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
#      #search_columns << { "name" => "taxon_id", "type" => "integer"}
#    end
end
