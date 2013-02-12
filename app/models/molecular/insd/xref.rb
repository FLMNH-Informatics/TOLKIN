#class Insd::Xref < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_xref'
#
#  has_and_belongs_to_many :features,
#    class_name: 'Insd::Feature',
#    join_table: 'insd_feature_xrefs',
#    foreign_key: 'xref_pk',
#    association_foreign_key: 'feature_pk'
#end