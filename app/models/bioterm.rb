# == Schema Information
# Schema version: 20090423194502
#
# Table name: term
#
#  term_id     :integer         not null, primary key
#  name        :string(255)     not null
#  definition  :text
#  identifier  :string(40)
#  is_obsolete :string(1)
#  ontology_id :integer         not null
#
class Bioterm < ActiveRecord::Base
  self.primary_key = 'term_id'
  self.table_name = 'term'
end
