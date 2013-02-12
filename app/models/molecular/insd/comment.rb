#class Molecular::Insd::Comment < ActiveRecord::Base
#  self.primary_key = 'pk'
#  self.table_name = 'insd_comment'
#
#  has_and_belongs_to_many :seqs,
#    class_name: 'Insd::Seq',
#    join_table: 'insd_seq_comment_set',
#    foreign_key: 'comment_pk',
#    association_foreign_key: 'seq_pk'
#
#  has_many :paragraphs, class_name: 'Molecular::Insd::Comment::Paragraph'
#
#  def destroy
#    self.transaction do
#      paragraphs.each(&:destroy)
#      super
#    end
#  end
#end
