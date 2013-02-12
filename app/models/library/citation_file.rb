# == Schema Information
# Schema version: 20090423194502
#
# Table name: citation_files
#
#  id            :integer         not null, primary key
#  file_name     :string(255)     not null
#  file_size     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  original_name :string          not null
#

  #has_attachment :storage => :file_system,
  #               :max_size => 500.kilobytes
  
#name currenlty not search friendly need to exchange the usage of original_name and name since searchlogic defaults to searching on _name_like for foreign key.
class Library::CitationFile < ActiveRecord::Base
  validates_presence_of :name, :original_name
end
