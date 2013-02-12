
require 'models/mixins/paranoid_lite'
require 'models/mixins/scope_limitable'

class Taxon < Record
  include GenericSearch

  self.auto_complete_text_method = :name

  has_and_belongs_to_many :citations, :class_name => 'Library::Citation'
  has_many :taxa_images, class_name: 'TaxonImage', as: :object
  has_many :images, through: :taxa_images, include: :thumb
  has_one  :protologue, class_name: 'ProtologueFile'

  has_many :dna_samples, class_name: "Molecular::DnaSample"
  has_many :collections
  has_many :sequences, class_name: "Molecular::Insd::Seq"
  belongs_to :project, foreign_key: :owner_graph_rtid, primary_key: :rtid
  belongs_to :namestatus
  belongs_to :accepted_name, class_name: "Taxon", primary_key: :taxon_id
  belongs_to :parent, foreign_key: :parent_taxon_id, primary_key: :taxon_id, class_name: 'Taxon'
  has_many :synonyms, :class_name => 'Taxon', :foreign_key => :accepted_name_id, :primary_key => :taxon_id

  after_create :create_and_attach_to_otu
  before_destroy :remove_seqs

  scope :root, lambda{
    where(parent_taxon_id: nil)
  }
#  named_scope :is_root_taxon, lambda{ |t_or_f|
#    { conditions: {
#        parent_taxon_id: (t_or_f ? nil : fail('no false for is_root_taxon right now'))
#    } }
#  }

#  composite :namestatus, :'namestatus.status'
#  delegate :namestatus, to: :vtattrs

  # handle empty strings
  def self.before_validation
    attr = self.attributes
    attr.each do |k,v|
      attr[k] = nil if v.respond_to?(:size) && v.size < 1
    end
    self.attributes=attr
  end


#  validates_presence_of :name, :project_id, :recpermission_id, :message => "Missing required field"
  #validates_uniqueness_of :name, :scope => [:project_id, :old_accepted_name, :author, :year, :infra_name, :infra_author, :publication_date ]
#  validates_presence_of :name,:project_id, :recpermission_id, :message => "Missing required field"
  
#  validates_each :name do |record, attr, value| # check name within scope of paranoid_lite - need to validate correctly both for new and update
#    old = record.id ? self.find(record.id) : nil
#    if(!old || old.name != record.name)
#      record.errors.add attr, 'is not unique.' if self.first(conditions: {
#          attr => value,
#          project_id:        record.project_id,
#          deleted_at:        record.deleted_at,
#          author:            record.author,
#          infra_name:        record.infra_name,
#          infra_author:      record.infra_author,
#          publication_date:  record.publication_date
#      })
#    end
#  end

  select_scope :css_class, {
    select: [ :namestatus_id ],
    include: { namestatus: { select: [ :id, :status ] } }
  }
  def css_class
    (namestatus && namestatus.status == 'accepted_name') ? 'b' : nil
  end

  def remove_seqs
    self.sequences.each{|seq| seq.update_attributes(:taxon_id => nil)}
  end



  select_scope :label, { 
    select: [ :name, :author, :infra_author, :publication, :volume_num, :pages, :publication_date ]
  }
  def label
    ((((
    ('' << name) <<
    (author.blank? ? (infra_author.blank? ? '' : " #{infra_author}, ") : " #{author}, ")) <<
    #(author.blank? && infra_author.blank? ? "" : " #{author||infra_author}, ")) <<
    (publication.blank? ? "" : "#{publication} ")) <<
    (volume_num.blank? ? "" : "#{volume_num}: ")) <<
    (pages.blank? ? "" : "#{pages}. " )) <<
    (publication_date.blank? ? "" : "#{publication_date}." )
  end

  #validates_each :accepted_name_id do |record, attr, value|
  #  record.errors.add attr, 'has accepted name without being synonym.' unless value.nil? || record.namestatus.status == 'synonym'
  #end


  # taxon given for accepted name must have namestatus set as 'accepted_name'
#  validates_each :accepted_name do |model, attr, value|
#    if value
#      unless value.namestatus and value.namestatus.status == 'accepted_name'
#        model.errors.add(attr, "Namestatus for taxon given is not 'accepted_name'")
#      end
#    end
#  end
# TODO Finish this: very important!
  def self.destroy_if_authorized(ids, user, options = { })
    @successful, @failed = [ ], [ ]
    [*ids].each do |id|
      begin
        @entry = self.find(id)
        fail "user is not authorized" unless user.can_delete?(@entry)
        fail Exception::HasChildren, @entry unless options[:child_options] || @entry.children.empty?
        @entry.destroy
        @successful << { :id => id, :label => @entry.label }
      rescue Exception::HasChildren => exception
        @failed << { :id => id, :label => @entry.label, :errors => [ exception.to_hash ] }
      end
    end
    [ @successful, @failed ]
  end

  def display_attr_val # a reader
    self.name
  end

  def self.name_status(taxon)
    #
    if !taxon.namestatus.nil?
      taxon.namestatus.status
    else
      nil
    end
  end

  def has_descendants?
    has_children == true
  end

  def to_s
    name
  end

#  def self.root_taxa_for_project(project_id)
#    Taxon.find(:all, :select=>"*", :conditions=> ["project_id =? and parent_taxon_id IS NULL", project_id], :order=> "name")
#	end

  @sel = false
  def selected?
    @sel
  end

  def selected=(value)
    @sel = value
  end

  def self.delete_multiple(tax_ids, delete_recursive, current_project)
#    deleted_list = Array.new
#    tax_ids.each do |id|
#      tax = current_project.taxa.find(id)
#      if tax
#        if delete_recursive && tax.children.size > 0
#          deleted_list  << Taxon.delete_multiple( tax.children.collect{|child| child.id}, delete_recursive, current_project)
#        else
#          tax.children.each do |child|
#            child.parent = tax.parent
#            child.save!
#          end
#        end
#        tax.reload
#        tax.destroy()
#        deleted_list << id
#      end
#    end
#    deleted_list.flatten

  end

#  def basionym_of
#    basionym_of_id = TaxaRelationship.first(conditions: { subject_taxon_id: self.id, predicate_id: Predicate.find_by_name('is_basionym_of')}).try(:object_taxon_id)
#    basionym_of_id ? Taxon.find(basionym_of_id) : nil
#  end

  def self.fetch_taxon(id)
    current=Taxon.find(id)
    raise "Taxon Not Found" if current.nil?
    return  current, current.parent, current.children
  end

  def move_to(name) #TODO this should be changed to id, after hacking the in_place_editor a bit
    new_parent = Taxon.find_by_name(name)
    self.parent_taxon = new_parent
    save
  end

  def self.fetch_children(id, param_selected)
    current = self.find(id)
    children = current.children
    if !param_selected.nil? && param_selected == "true"
      current.selected = true;
      children.each do |child|
        child.selected = true;
      end
    end
    return current, children
  end

  def add_citations(add_ids)
    self.transaction do
      prev_ids = self.citations.collect{ |c| c.id.to_s }
      remaining_ids = add_ids && (add_ids - prev_ids)
      remaining_ids.each do |cit_id|
        self.citations << self.project.citations.find(cit_id) || fail('could not add citation')
      end
    end
  end

  def publication_info

      if  publication != nil && publication.strip() != '' && volume_num !=nil && volume_num.strip() != '' && pages != nil && pages != ''
         ((((publication << ' ') << volume_num) << ' ') << pages)
      elsif publication != nil && publication != '' && volume_num != nil && volume_num = '' && pages != nil && pages != ''
        ((publication || ' ') || pages)
      elsif publication != nil && publication != '' && volume_num != nil && volume_num != '' && pages != nil && pages == ''
        ((publication || ' ') || volume_num)
      elsif publication != nil && publication = '' && volume_num != nil && volume_num != '' && pages != nil && pages != ''
        ((volume_num || ' ') || pages)
      elsif publication != nil && publication = '' && volume_num != nil && volume_num = '' && pages != nil && pages != ''
        pages
      elsif publication != nil && publication = '' && volume_num != nil && volume_num != '' && pages != nil && pages == ''
        volume_num
      else
        publication
      end

  end

  def accepted_name_label
        self.accepted_name.name
  end

  def namestatus_label
        self.namestatus.status
  end

  def self.find_by_otu_name(otu)
    Taxon.where(:name => otu.name, :owner_graph_rtid => otu.project.rtid).first
  end

  

    #[ "name", "author", "year", "types", "type_country", "general_distribution", "descriptiton", "volumne_num", "pages", "infra_name", "infra_author", "herbaria", "neotype", "sub__genus"]
  private

      def create_and_attach_to_otu
        otu = Otu.new
        otu.name, otu.project_id, otu.creator_id = self.name, self.project.project_id, User.where('rtid = ?', self.creator_rtid).first.user_id
        otu.save!
        otu.taxa << self
      end
  
      def self.searchable_columns
        @searchable_columns  ||= get_searchable_columns
      end

      def self.get_searchable_columns
        # UNFINISHED
  #      titles = ["Subgenus", "Section", "Species", "Author", "Infra name", "Infra author", "Genral Distribution", "Description", "Publication Tiltle", "Publication Date"]
        search_columns =  [
          { column: "name", label: 'Species' , active: true},
          { column: "sub_genus", label: 'Subgenus', active: true} ,
          { column: "section"},
          { column: "subsection"},
          { column: "editors"},
          #{ column: "collection"}
          { column: "namestatus_id", label: 'Name Status'},
          { column: "author"},
          { column: "infra_name"},
          { column: "infra_author"},
          { column: "general_distribution", active: true},
          { column: "description"},
          { column: "publication", label: 'Publication Title' },
          { column: "publication_date"}#,
         # { column: "editor" }
        ].inject([])  do | filters ,column|
          col_name = column[:column]
          col_info = columns_hash[col_name] || self::Vtattrs.columns_hash[col_name] #|| method_defined?(col_name)
          throw "#{col_name} not found in taxon" unless col_info
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

#      [
#       { "name" => "sub_genus", "label" => "Subgenus", "type" => "string"},
#       { "name" => "section", "label" => "Section", "type" => "string"},
#       { "name" => "subsection", "label" => "Subsection", "type" => "string"},
#       { "name" => "name", "label" => "Species", "type" => "string"},
#       { "name" => "namestatus", "label" => "Name Status", "type" => "select"},
#       { "name" => "author", "label" => "Author", "type" => "string"},
#       { "name" => "infra_name", "label" => "Infra name", "type" => "string"},
#       { "name" => "infra_author", "label" => "Infra author", "type" => "string"},
#       { "name" => "general_distribution", "label" => "General distribution", "type" => "string"},
#       { "name" => "description", "label" => "Description", "type" => "string"},
#       { "name" => "publication", "label" => "Publication Title", "type" => "string"},
#       { "name" => "publication_date", "label" => "Publication date", "type" => "string"}
#      ]
      #search_columns << { "name" => "otu_groups_id", "type" => "integer"}
    end

end
