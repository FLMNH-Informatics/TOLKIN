class Morphology::Character < ActiveRecord::Base
  include GenericSearch
  include WithNameLike
  include TempVersioned


  attr_accessor :auto_complete_text_method
  #self.auto_complete_text_method = :name

  belongs_to :project
  has_many :chr_states, :class_name => "Morphology::ChrState", :order => :state


  has_many :characters_chr_groups, :class_name => 'Morphology::CharactersChrGroups'
  has_many :chr_groups, :through => :characters_chr_groups

  has_many :timelines, :through => :matrices_characters
  has_many :matrices_characters, :class_name => "Morphology::Matrix::MatricesCharacters", :foreign_key => "character_id"

  has_many :cells,
           :class_name => "Morphology::Matrix::Cell",
           :foreign_key => "character_id"

  has_many :character_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :character_images

  has_and_belongs_to_many :citations, :class_name => "Library::Citation"

  has_many :state_codings, :class_name => "Morphology::StateCodings"

  belongs_to  :creator, :class_name => "User"
  belongs_to  :updator, :class_name => "User"

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }
  select_scope :chr_groups_joined, {
    include: { chr_groups: { select: [ 'id', 'name' ]} }
  }
  def chr_groups_joined
    chr_groups.collect(&:name).join(', ')
  end

  #TODO could be much better, need to overoverwite method_missing
  def create_clone options = {}, &block
    self.transaction do
      record = clone
      record.attributes = { updator_id: nil, updated_at: nil }.merge options
      if block_given?
        yield(record)
      end
      record.save!
      record.chr_states << self.chr_states.collect do |chr_state|
        obj = chr_state.clone
        obj.citations = chr_state.citations
        obj.character = record
        obj.save!
        obj.images << chr_state.images
        obj
      end
      record.citations << self.citations
      record.images << self.images
      record
    end
  end

  def self.search_name name
    self.find_by_project_id(current_project.id, :conditions => "name ILIKE '%#{name}%'" )
  end

  def states
    chr_states
  end

  def get_state_number
    self.states.count
  end


  def equivalent_in(characters)
    characters.each do |character|
      is_match = true
      is_match = false unless character.name.downcase.gsub(/[\s\(\)\-\/]/, '') == name.downcase.gsub(/[\s\(\)\-\/]/, '')
      if is_match
        states.each do |state|
          is_match = false if character.states.select {|state_match| state.name.downcase.gsub(/[\s\(\)\-\/]/, '') == state_match.name.downcase.gsub(/[\s\(\)\-\/]/, '') && state.state == state_match.state}.empty?
        end
      end
      return character if is_match == true
    end
    nil
  end

  def add_to_timeline(timeline)
    timeline.characters << self
    self.create_clone(self.attributes)
  end

  def self.auto_complete_text_method

  end

  private
      def self.searchable_columns
              @searchable_columns  ||= get_searchable_columns
      end
    def self.get_searchable_columns
      search_columns =  [ "name", "description" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
      #search_columns << { "name" => "chr_groups_id", "type" => "integer"} problematic - no search available on multi-id foreign key columns at present time
    end
end
