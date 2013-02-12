class ImageJoin < ActiveRecord::Base
  self.table_name = 'images_joins'

  belongs_to :object, polymorphic: true
  belongs_to :image
end