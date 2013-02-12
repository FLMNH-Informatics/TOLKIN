# == Schema Information
# Schema version: 20090423194502
#
# Table name: publication_files
#
#  id          :integer         not null, primary key
#  file_name   :string(255)
#  size        :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_typ :string
#

class Library::PublicationFile < ActiveRecord::Base
#  has_attachment :storage => :file_system,
#                 :max_size => 500.kilobytes
#  validates_as_attachment
  
end
