#class Insd::FeatureSet < ActiveRecord::Base
#  self.table_name = 'insd_feature_set'
#  self.primary_key = 'pk'
#
#  has_and_belongs_to_many :features,
#    class_name: 'Insd::Feature',
#    join_table: 'insd_feature_set_features',
#    foreign_key: 'feature_set_pk',
#    association_foreign_key: 'feature_pk'
#
#  def destroy
#    self.transaction do
#      features.each(&:destroy)
#      super
#    end
#  end
#end