# == Schema Information
# Schema version: 20090423194502
#
# Table name: annotations
#
#  id            :integer         not null, primary key
#  collection_id :integer         not null
#  taxon         :string(255)
#  name          :string(255)
#  date          :string
#  inst          :string(255)
#

class Annotation < ActiveRecord::Base
		belongs_to  :collector,
		:class_name => "Collections",
		:foreign_key => "collection_id"
    belongs_to :collection,
    :class_name => "Collection",
    :foreign_key => "collection_id"
end
