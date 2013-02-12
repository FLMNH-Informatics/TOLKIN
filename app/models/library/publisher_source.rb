# == Schema Information
# Schema version: 20090423194502
#
# Table name: publisher_sources
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#

class Library::PublisherSource < ActiveRecord::Base
  belongs_to :project
  has_many :publishers, :class_name => "Library::Publisher"
end
