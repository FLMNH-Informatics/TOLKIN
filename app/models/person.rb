class Person < ActiveRecord::Base
  include GenericSearch

  has_one :user
  belongs_to :project
  #validates_presence_of :first_name
  #validates_presence_of :last_name
  has_many :contributorships, :class_name => "Library::Contributorship"
  has_many :citations, :through => :contributorships, :class_name => "Library::Citation"
  
  
  #has_many :advanced_searches
  
  @@search_columns = { :first_name => :first_name, :last_name => :last_name, :middle_name => :middle_name}

  def search_columns
    @@search_columns
  end

  def <=> p2
     label <=> p2.label
  end

  def label
    if first_name && !first_name.empty? && last_name && !last_name.empty?
      "#{first_name} #{last_name}"
    elsif first_name && !first_name.empty?
      first_name
    elsif last_name && !last_name.empty?
      last_name
    else
      ''
    end
  end

  def initials_label
    "#{initials} - #{first_name} #{last_name}"
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def first_last
    "#{first_name} #{last_name}"
  end

  select_scope :name_citation_formatted, {
    select: [ :first_name, :last_name ]
  }
  def name_citation_formatted
    last_first
  end
  
  def last_first
    [ last_name, first_name.blank? ? nil : first_name ].compact.join(', ')
    #"#{last_name}, #{first_name}"
  end

  select_scope :display_name, {
    select: [
      :prefix,
      :first_name,
      :last_name,
      :middle_name,
      :suffix
    ]
  }
  def display_name
    [ prefix.blank? ? nil : prefix,
      last_name.blank? ? nil : last_name,
      first_name.blank? ? nil : first_name,
      middle_name.blank? ? nil : middle_name,
      suffix.blank? ? nil : suffix
    ].compact.join(' ')
#    if
#      full_name.concat(prefix)
#    end
#    if !last_name.blank?
#      full_name.concat(last_name.humanize)
#    end
#    if !first_name.blank?
#      full_name.concat(first_name.humanize)
#    end
#    if !middle_name.blank?
#      full_name.concat(middle_name.humanize)
#    end
#    if !suffix.blank?
#      full_name.concat(suffix.humanize)
#    end
#    full_name.underscore.humanize.titleize
  end

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

  def to_s
    label
  end

  #used to hash the first last and middle name from a compound name with the seperator. used from the citation parser
  def Person.hash_split_names(name, splitter=',')
    return  { :last_name => temp[0], :first_name => temp[1], :middle_name => temp[2]}.each_pair { |key,val|  val.strip!.downcase! if val}
  end

  #def to_param
  #  param_name = first_last.gsub(" ", "_")
  #  param_name = param_name.gsub(/[^A-Za-z0-9_]/, "")
  #  "#{id}-#{param_name}"
  #end

  # Person Contributorship Calculation Fields

  #A person's image file
  #def image_url
  #  if !self.image.nil?
  #    self.image.publi acts_as_authorizable  #some actions on people require authorization
  #serialize :scoring_hash
  #has_many :name_strings, :through => :pen_names
  #has_many :pen_names
  #has_many :groups, :through => :memberships
  #has_many :memberships
  
  # has_many :citations, :through => :contributorships do 
  
  
  # has_many :contributorships do 
  # has_one :image, :as => :asset do
  
end
