#require 'publifier'

class Chromosome::Probe < ActiveRecord::Base

  include GenericSearch
  #before_create lambda{ self.public_record = true }
  validates :value, :presence => true

  has_many :hybridizations

  #has_and_belongs_to_many :sequence_contigs, :join_table => "contigs_probes"
  #has_and_belongs_to_many :insd_seq, :class_name => "Molecular::Insd::Seq", :join_table => "probes_seqs", :foreign_key => "probe_id", :association_foreign_key => "insd_seq_id"
  #has_and_belongs_to_many :z_files, :join_table => "probes_zfiles", :uniq => true, :class_name => "Chromosome::ZFile", :foreign_key => "probe_id", :association_foreign_key => "z_file_id"

  #has_and_belongs_to_many :dye_compositions, :join_table => "probes_dye_compositions"
  #has_many :dyes

  scope :for_project, lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }


#  belongs_to :projects

   def z_files
     self.hybridizations.collect {|h| h.z_file}
   end

   def dyes
     self.hybridizations.collect {|h| h.dye}
   end

  def hybridize(dye)
    Chromosome::Hybridization.create!({:probe_id => self.id, :dye_id => dye.id})
  end
  
end
