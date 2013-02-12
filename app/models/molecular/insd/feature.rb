#class Molecular::Insd::Feature < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_feature'
#
#  has_and_belongs_to_many :intervals,
#    class_name: 'Insd::Interval',
#    join_table: 'insd_feature_intervals',
#    foreign_key: 'feature_pk',
#    association_foreign_key: 'interval_pk'
#
#  has_and_belongs_to_many :quals,
#    class_name: 'Insd::Qualifier',
#    join_table: 'insd_feature_quals',
#    foreign_key: 'feature_pk',
#    association_foreign_key: 'qualifier_pk'
#
#  has_and_belongs_to_many :xrefs,
#    class_name: 'Insd::Xref',
#    join_table: 'insd_feature_xrefs',
#    foreign_key: 'feature_pk',
#    association_foreign_key: 'xref_pk'
#
#  has_and_belongs_to_many :feature_sets,
#    class_name: 'Insd::FeatureSet',
#    join_table: 'insd_feature_set_features',
#    foreign_key: 'feature_pk',
#    association_foreign_key: 'feature_set_pk'
#
#  alias :qualifiers :quals
#
#  def destroy
#    self.transaction do
#      intervals.each(&:destroy)
#      quals.each(&:destroy)
#      xrefs.each(&:destroy)
#      super
#    end
#  end
#end
