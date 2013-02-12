
class Project < Record

  self.primary_key="project_id"

  has_and_belongs_to_many :default_permission_sets, 
    class_name: 'PermissionSet',
    join_table: :project_default_permission_sets, 
    primary_key: :rtid,
    foreign_key: :project_rtid, 
    association_primary_key: :rtid,
    association_foreign_key: :permission_set_rtid

  def default_permission_set
    default_permission_sets.first
  end

  def projects
    Project.where(:rtid ^ self.rtid).joins(:rsattrs).where(:rsattrs => { :owner_graph_rtid => self.rtid })
  end

  def users
    User.with_project(self)
  end

  def permission_sets
    ::PermissionSet.in_project(self)
  end

  def taxa
    fail "dont use me im not secure"
#    Taxon.with_project(self)
  end

  def roles
    Role.with_project(self)
  end

  def name
    label
  end

  has_many :alignments, :class_name => 'Molecular::Alignment'
  has_many :people, :class_name => 'Person'
  has_many :authors, :class_name => 'Library::Author'
  has_many :citations, :class_name => 'Library::Citation'
  has_many :publishers, :class_name => 'Library::Publisher'
  has_many :publications, :class_name => 'Library::Publication'
#  has_many :taxa, :class_name => 'Taxon'
  has_many :collections
#  has_many :bioentries, :class_name => 'Molecular::Bioentry'
  has_many :sequences,  class_name: 'Molecular::Insd::Seq'
  has_many :matrices, :class_name => 'Morphology::Matrix'
  has_many :characters, :class_name => 'Morphology::Character'
  has_many :primers, :class_name => 'Molecular::Primer'
  has_many :chr_groups, :class_name => 'Morphology::ChrGroup'
  has_many :dna_samples, :class_name => 'Molecular::DnaSample'
  has_many :otus
  has_many :morphology_matrix_checkpoints, :class_name => 'Morphology::Matrix::Checkpoint'
  has_many :morphology_matrix_views, :class_name => 'Morphology::MatrixView'
  has_many :morphology_matrices, :class_name => 'Morphology::Matrix'
  has_many :morphology_matrix_timelines, :class_name => 'Morphology::Matrix::Timeline', :through => :morphology_matrices, :source => :timelines
  has_many :molecular_matrices, :class_name => 'Molecular::Matrix'
  has_many :molecular_matrix_timelines, :class_name => 'Molecular::Matrix::Timeline', :through => :molecular_matrices, :source => :timelines
  has_many :molecular_matrix_views, :class_name => 'Molecular::MatrixView'
  has_many :state_codings, :class_name => 'Morphology::StateCoding'
  has_many :mol_cells, :through => :otus
  has_many :otu_groups
  has_many :granted_roles
  has_many :nexus_datasets
  has_many :branches, :class_name => "Matrix::Branch"
  has_many :changesets, :through => :branches
  has_many :matrix_branches, :class_name => "Matrix::Branch"
  has_many :character_branches, :class_name => 'Morphology::CharacterBranch'
  has_many :otu_branches
  has_many :markers, :class_name => "Molecular::Marker"
  has_many :plastome_tables, :class_name => "Molecular::Plastome::Table"
  has_many :mol_matrix_cell_statuses, :class_name => "Molecular::Matrix::Cell::Status"
  has_many :images
  has_many :primers, :class_name => 'Molecular::Primer'
  has_many :primer_genes, :class_name => 'Molecular::PrimerGene'
  has_many :primer_target_organisms, :class_name => 'Molecular::PrimerTargetOrganism'
  has_many :primer_purification_methods, :class_name => 'Molecular::PrimerPurificationMethod'
  has_many :fasta_filenames, :class_name => 'Molecular::FastaFilename'

  has_many :book_titles, class_name: 'Library::PublicationTitle', conditions: { publication_type: 'book' }
  has_many :publication_titles, class_name: 'Library::PublicationTitle'
  has_many :chr_images, class_name: 'Chromosome::ChrImage'
  has_many :dyes, class_name: 'Chromosome::Dye'
  has_many :sequence_contigs, class_name: 'Chromosome::SequenceContig'
  has_many :probes, class_name: 'Chromosome::Probe'
  has_many :z_files, class_name: 'Chromosome::ZFile'
  has_many :dye_compositions, class_name: 'Chromosome::DyeComposition'
  has_many :custom_mappings, class_name: 'CustomMapping'
  has_one  :public_license
  has_many :public_records
  #validates_presence_of :name
  #validates_uniqueness_of :name
  #validates_presence_of :institution

  scope :scope_all, :conditions => { } # including this because Project.all returns an array rather than a scope
  scope :for_user, lambda { |user|
    self.
      joins(:granted_roles).
      where(granted_roles: { user_id: user.user_id })
  }

  alias :seqs :sequences

  class << self

    def tolkin_project
      Project.
        joins(:vsattrs => :vtattrs).
        where(:vsattrs => { :vtattrs => { :label => 'Tolkin' }}).
        first
    end
  end

#  def id; project_id end
#  def vtattrs; vsattrs.vtattrs end
#  def logo; vtattrs.logo end
#  def name; vtattrs.label end
#  def website; vtattrs.website end

  def managers(options = { })
    people_with_rank(3, options)
  end

  def updaters(options = { } )
    people_with_rank(2, options)
  end

  def people_in_group(group, current_user)
    case group.try(:to_sym)
    when nil, :viewers
      current_user.manages?(self) ? viewers : raise("invalid permissions to see viewers")
    when :updaters then updaters
    when :managers then managers
    else raise('invalid group parameter')
    end
  end

  def viewers(options = { })
    people_with_rank(1, options)
  end

  def to_s
        self.name
  end
  
  private

  def people_with_rank(rank, options = { })
    Person.find(:all, ({
          :select => 'people.*',
          :order => 'people.last_name, people.first_name',
          :include => { :user => { :granted_roles => [ :project, :role_type ] } },
          :conditions => [ "role_types.rank >= ? and projects.id = ?", rank, self.id ]
        }.merge(options)))
  end

end
