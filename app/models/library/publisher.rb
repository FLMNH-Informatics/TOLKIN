# == Schema Information
# Schema version: 20090423194502
#
# Table name: publishers
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  sherpa_id        :integer
#  source_id        :integer
#  authority_id     :integer
#  publisher_copy   :boolean
#  url              :string(255)
#  romeo_color      :string(255)
#  copyright_notice :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  project_id       :integer
#  user_id          :integer
#  last_updated_by  :integer
#

class Library::Publisher < ActiveRecord::Base
  include GenericSearch
  
  belongs_to :project
  belongs_to :user
  has_many :publications, :class_name => "Library::Publication"
  belongs_to :authority,
    :class_name => "Library::Publisher",
    :foreign_key => :authority_id

  belongs_to :publisher_source,
    :class_name => "Library::PublisherSource",
    :foreign_key => :source_id

  validates_presence_of :name
  #has_many :citations, :conditions => ["citation_state_id = 3"]
  
  before_update :updating
  before_create :creating
  
  private
  def updating
    self.updated_at = Time.now
  end
  
  def creating
    self.created_at = Time.now
  end

    # [ "name"]
  private
      def self.searchable_columns
        @searchable_columns  ||= get_searchable_columns
      end
    def self.get_searchable_columns
      search_columns =  [ "name"].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
      #search_columns << { "name" => "otu_groups_id", "type" => "integer"}
    end
end
