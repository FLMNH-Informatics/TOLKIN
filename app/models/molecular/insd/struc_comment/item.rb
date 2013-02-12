class Molecular::Insd::StrucComment::Item < ActiveRecord::Base
  self.table_name = 'insd_struc_comment_item'
  self.primary_key = 'pk'

  belongs_to :struc_comment, class_name: 'Molecular::Insd::StrucComment'
end
