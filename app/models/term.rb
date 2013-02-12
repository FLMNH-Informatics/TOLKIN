# To change this template, choose Tools | Templates
# and open the template in the editor.

class Term < ActiveRecord::Base


  belongs_to :ontology, :class_name => 'Ontology', :foreign_key => 'ontology_id'
#  has_one :feature_qualifier_relationship

  self.table_name = 'term'
end
