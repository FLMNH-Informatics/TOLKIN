class CustomMapping < ActiveRecord::Base
  include GenericSearch

  self.table_name = 'custom_mappings'
  #self.table_name = 'bulk_uploads_custom_mappings'

  validates :mapping, :presence => true

  belongs_to :user

  belongs_to :project

  belongs_to :collections_bulk_upload, :class_name => 'Collections::BulkUpload'

  # To change this template use File | Settings | File Templates.
  class << self
    def for_module type
      where(:type => type)
    end
  end

  def get_map
    JSON.parse(self.mapping)
  end

  def map_hash
    JSON.parse(self.mapping)
  end

  def for_type type
    for_module type
  end

  def self.for_module type
    self.where(:type => type.to_s)
  end
end