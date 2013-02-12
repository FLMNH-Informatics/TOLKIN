class ProtologueFile < ActiveRecord::Base
  belongs_to :taxon

  has_attached_file :protologue,
    :storage => :filesystem,
    :url => "/private/storage/taxon/:id_partition/:filename",
    :path  => ":rails_root:url"
    #:max_size => 20.megabyte


end
