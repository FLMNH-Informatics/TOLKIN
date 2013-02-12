class Molecular::Alignment < ActiveRecord::Base
  include GenericSearch
  require 'bio'
  belongs_to :creator, class_name: 'User'
  belongs_to :updater, class_name: 'User'
  belongs_to :project
  has_many :sequences, :through => :alignment_seqs, :class_name => 'Molecular::Insd::Seq'
  has_many :alignment_seqs
  has_many :alignment_outputs, :class_name => 'Molecular::Alignment::AlignmentOutputs'

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }


  def to_fasta
    self.sequences.collect{|seq| seq.to_fasta}.join("")
  end

  def timeline
    self.timeline_id.blank? ? nil : Molecular::Matrix::Timeline.find(self.timeline_id)
  end

  def output type
    outputs = self.alignment_outputs.where('alignment_type = ?', type)
    if self.alignment_outputs.where('alignment_type = ?', type).empty?
      false
    else
      outputs.first.alignment_text
    end
  end

  def alignments_hash
    h = {}
    self.alignment_outputs.each { |output| h[output.alignment_type] = output.alignment_text }
     h
  end

  def output_alignment type
    ##TODO: INCLUDE CORRECT PARAMETERS FOR OUTPUT FROM CLUSTALW
    case type
      when :clustal
        factory = Bio::ClustalW.new
        self.to_bio_alignment.do_align(factory).output(type)
      when :molphy

      when :msf

      when :phylip

      when :phylipnon

    end
    self.to_bio_alignment.do_align(factory).output(type)
  end

  def to_bio_alignment
    new_align = Bio::Alignment::OriginalAlignment.new()
    self.sequences.each{|s| new_align.add_seq(s.sequence, s.organism.split(' ').join('_')+"_"+ s.pk.to_s)}
    new_align
  end

  def remove_seq seq_id
    a_seq = self.alignment_seqs.where('seq_id = ?', seq_id).first
    self.alignment_seqs.destroy(a_seq.id)
  end

  private
    def self.searchable_columns
      @searchable_columns  ||= get_searchable_columns
    end

    def self.get_searchable_columns
      search_columns =  [ "name",  "description", "seq" ].inject([])  do | filters ,col_name|
        raise "filter not found: #{col_name}" unless columns_hash[col_name]
        filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s }
      end
    end
end
