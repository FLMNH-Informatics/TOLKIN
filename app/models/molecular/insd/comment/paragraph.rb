#class Molecular::Insd::Comment::Paragraph < ActiveRecord::Base
#  self.table_name = 'insd_comment_paragraph'
#  self.primary_key = 'pk'
#
#  belongs_to :comment, class_name: 'Molecular::Insd::Comment'
#  has_many :items, class_name: 'Molecular::Insd::Comment::Paragraph::Item'
#
#  def destroy
#    self.transaction do
#      items.each(&:destroy)
#      super
#    end
#  end
#end
