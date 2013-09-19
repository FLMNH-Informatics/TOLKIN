class Molecular::Insd::Seq < ActiveRecord::Base
  include GenericSearch
  require 'bio'
  attr_accessor :auto_complete_text_method
  cattr_reader :per_page
  @@per_page = 10

  has_many :matrix_cells_as_primary,
           :class_name => 'Molecular::Matrix::Cell',
           foreign_key: 'primary_sequence_id'

  has_and_belongs_to_many :cells,
                          :class_name => 'Molecular::Matrix::Cell',
                          join_table: 'mol_matrix_cell_sequences',
                          foreign_key: 'seq_id',
                          association_foreign_key: 'cell_id'

  has_many    :sequence_contigs,
              class_name: 'Chromosome::SequenceContig',
              foreign_key: 'insd_seq_pk'

  has_and_belongs_to_many  :probes,
                          :class_name => 'Chromosome::Probe',
                          :join_table => "probes_seqs",
                          :foreign_key => 'seq_id'

  has_many    :markers,
              :through => :seq_markers,
              :class_name => 'Molecular::Marker'

  has_many    :seq_markers,
              :dependent => :delete_all

  has_many    :alignments,
              :through => :alignment_seqs,
              :class_name => 'Molecular::Alignment'

  has_many    :alignment_seqs

  belongs_to  :fasta_filename,         class_name: 'Molecular::FastaFilename', foreign_key: 'fasta_filename_id'

  belongs_to :feature_set,  class_name: 'Molecular::Insd::FeatureSet'
  belongs_to :alt_seq_data, class_name: 'Molecular::Insd::AltSeqData'
  belongs_to :project, foreign_key: :project_id
  belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'taxon_id'


  self.primary_key = 'pk'
  self.table_name = 'insd_seq'

  before_save   :set_metadata_and_cascade_to_cell_information

  composite :id, [:pk ]

  scope :for_fasta_filename, lambda { |id|      { :conditions => [ "fasta_filename_id = ?", id] } }
  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }
  scope :taxon_name,         lambda { |value|   { :conditions => [ "taxa.name ilike ?", "%#{value}%" ] } }

  def self.from_project_with_marker_and_otu(project,marker,otu)
    taxon = Taxon.find_by_otu_name(otu)
    if taxon
      Molecular::Insd::Seq.joins(:seq_markers).where({
          :project_id => project.project_id,
          :taxon_id => taxon.taxon_id
        } & {
          :seq_markers =>
               {:marker_id => marker.id}
        }
      )
    else
      nil
    end
  end

  def id
    pk
  end

  def destroy
    self.cells.each do |cell|
      cell.remove_seq(self)
      cell.save
    end
    super
  end


  def parse_fasta
    debugger
    'hi'
  end

  def self.from_biofasta(fasta, proj, filename)
    seq = Molecular::Insd::Seq.create!(:sequence   => fasta.seq.upcase,
                                       :definition => fasta.definition,
                                       :project_id => proj.project_id,
                                       :fasta_filename => filename )
    marker_names  = fasta.definition.scan(/(?<=tol_gene=\[)[-_a-zA-Z. :0-9\-\+]+(?=\])/)
    markers_with_locations = marker_names.collect{|name| Molecular::Marker.find_or_create_by_project_and_name(proj,name)}
    marker_names.each do |marker|
      split = marker.split(':').flatten
      name, location = split.first, split.second
      marker = Molecular::Marker.find_or_create_by_project_and_name(proj,name)
      seq_marker = location.nil? ? { :marker_id => marker.id } : { :marker_id => marker.id, :start_position => location.split('..').first, :end_position => location.split('..').second }
      seq.seq_markers.create!(seq_marker)
    end
    organism_name = fasta.definition.match(/(?<=tol_org=\[)[-_a-zA-Z. 0-9]+(?=\])/)
    unless organism_name.nil?
      taxon = Taxon.where('lower(name) = ? and owner_graph_rtid = ?', organism_name.to_s.gsub("_"," ").downcase, proj.rtid).first || Taxon.create!(:name => organism_name.to_s.gsub("_"," "), :project => proj)
      seq.taxon = taxon
      seq.organism = taxon.name
    end
    seq.save!
    seq.reload
    seq
  end

  def to_fasta
    header = ''
    header << 'tolkin|' + self.pk.to_s +  ' '
    header << '|gb|' + self.locus + ' '  if self.locus
    header << ((self.definition[-1]=='.') ? self.definition[0..-2] : self.definition) if self.definition
    return Bio::Sequence::NA.new(self.sequence.upcase).to_fasta(header, 60) #this method is deprecated (see bioruby), but it seems there isn't an alternative
  end

  def self.from_matrix_and_marker_and_otu(matrix, marker_or_marker_id, otu_or_otu_id)
    if marker_or_marker_id.class == Molecular::Marker && otu_or_otu_id.class == Otu
      cell = matrix.checkpoint.cells.includes(:sequences, :primary_sequence).where('otu_id = ? and marker_id = ?', otu_or_otu_id.id, marker_or_marker_id.id).first
    else
      cell = matrix.checkpoint.cells.includes(:sequences, :primary_sequence).where('otu_id = ? and marker_id = ?', otu_or_otu_id, marker_or_marker_id).first
    end
    cell.force_primary_sequence unless cell.nil?
  end

  def new
    super
  end

  def update_markers_fulltext
    self.markers_fulltext = self.markers.map{|marker| marker.name }.sort.join(', ')
  end

  def self.find_by_marker(marker)
    Molecular::Insd::Seq.where('marker_id = ?', marker.id)
  end

  private

  def set_metadata_and_cascade_to_cell_information
    self.sequence = self.sequence.upcase unless self.sequence.blank?
    self.length = self.sequence.length
    self.update_markers_fulltext
  end

  def self.from_gb gb_record
    @seq = Molecular::Insd::Seq.new()
  end

  def self.searchable_columns
    @searchable_columns ||= get_searchable_columns
  end

  def self.get_searchable_columns
    exclude_cols = ["pk",
                    "update_date",
                    "create_date",
                    "update_release",
                    "create_release",
                    "source_db",
                    "feature_set_pk",
                    "database_reference",
                    "alt_seq_pk",
                    "project_id",
                    "created_at",
                    "updated_at",
                    "creator_id",
                    "updater_id",
                    "taxon_id",
                    "markers_fulltext"]
    cols = self.column_names.inject([]) { |memo, name|
      unless exclude_cols.include?(name.to_s)
        memo.push({ column: name.to_s, label: name.to_s.split('_').join(' ').capitalize }) unless exclude_cols.include?(name.to_s)
      else
        memo
      end
    }
    search_columns =  ([ { column: "markers_fulltext", label: "Marker", active: true } ] | cols).inject([])  do | filters ,column|
        col_name = column[:column]
        col_info = columns_hash[col_name] #|| self::Vtattrs.columns_hash[col_name] #|| method_defined?(col_name)
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
