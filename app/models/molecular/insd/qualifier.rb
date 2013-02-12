#class Insd::Qualifier < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_qualifier'
#
#  has_and_belongs_to_many    :features,
#    class_name:              'Insd::Feature',
#    join_table:              'insd_feature_quals',
#    foreign_key:             'qualifier_pk',
#    association_foreign_key: 'feature_pk'
#end