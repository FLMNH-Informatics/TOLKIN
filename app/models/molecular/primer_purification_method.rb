class Molecular::PurificationMethod < ActiveRecord::Base
  include GenericSearch

#   default_scope :order => 'id'

  self.table_name = 'primer_purification_methods'

  belongs_to :project
  has_many   :primers
end
