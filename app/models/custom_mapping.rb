class CustomMapping < ActiveRecord::Base
  include GenericSearch

  self.table_name = 'bulk_uploads_custom_mappings'

  validates :map, :presence => true

  belongs_to :collections_bulk_upload, :class_name => 'Collections::BulkUpload'

  # To change this template use File | Settings | File Templates.
end