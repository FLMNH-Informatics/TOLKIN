class Morphology::ChrGroup < ActiveRecord::Base

  include GenericSearch
  has_many :characters_chr_groups, :class_name => 'Morphology::CharactersChrGroups', :order => 'position', :dependent => :destroy
  has_many :characters, :through => :characters_chr_groups, :order => 'position'
  belongs_to :creator, :class_name => "User"
  belongs_to :updator, :class_name => "User"
  belongs_to :project

  validates_uniqueness_of :name, :scope => :project_id, :message => 'Character Group with that name already exists, Please choose a different name.'
  validates_presence_of :name,
    :message => "of New Character Group can not be blank!"

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

  def full_name(creator_id)
    return  Person.find(:all, ({
          :select => 'v_people.last_name, v_people.first_name',
          :conditions => [ "v_people.id = ?", creator_id ]
        }))
  end

    private
      def self.searchable_columns
              @searchable_columns  ||= get_searchable_columns
      end
    def self.get_searchable_columns
      search_columns =  [ "name" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
      #search_columns << { "name" => "chr_groups_id", "type" => "integer"}
    end
end
