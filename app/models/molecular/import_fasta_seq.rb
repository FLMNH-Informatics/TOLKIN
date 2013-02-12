class Molecular::ImportFastaSeq < ActiveRecord::Base
  require 'bio'

  def self.from_filestring filestring #creates a BioFastaFormat for simpler parsing
    Bio::FastaFormat.new(filestring)
  end

end