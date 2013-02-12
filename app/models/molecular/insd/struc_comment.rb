class Molecular::Insd::StrucComment < ActiveRecord::Base
#  self.table_name = 'insd_struc_comment'
#  self.primary_key = 'pk'
#
#  has_and_belongs_to_many :seqs,
#    class_name: 'Insd::Seq',
#    join_table: 'insd_seq_struc_comments',
#    foreign_key: 'struc_comment_pk',
#    association_foreign_key: 'seq_pk'
#
#  has_many :items, class_name: 'Molecular::Insd::StrucComment::Item'
#
#  def destroy
#    self.transaction do
#      items.each(&:destroy)
#      super
#    end
#  end
#
end
