#class Molecular::Insd::Interval < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_interval'
#
#  has_and_belongs_to_many :features,
#    class_name: 'Insd::Feature',
#    join_table: 'insd_feature_intervals',
#    foreign_key: 'interval_pk',
#    association_foreign_key: 'feature_pk'
#end