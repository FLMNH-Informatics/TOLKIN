class TaxonImage < ActiveRecord::Base
  self.table_name = 'images_joins'

  default_scope conditions: { object_type: 'Taxon'}

  belongs_to :object, polymorphic: true
  belongs_to :image

  belongs_to :taxon, class_name: "Taxon", :foreign_key => 'object_id'
end