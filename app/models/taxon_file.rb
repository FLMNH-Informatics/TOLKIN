class TaxonFile < ActiveRecord::Base

  belongs_to :taxon
  
  has_attached_file :protologue,
    :storage => :filesystem,
    :path => " :rails_root/private/storage/taxon/:id_partition"
    #:max_size => 20.megabytes

  #validates_as_attachment
end
