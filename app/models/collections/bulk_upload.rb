class Collections::BulkUpload < ActiveRecord::Base
  require 'spreadsheet'

  include GenericSearch

  has_many :custom_mappings
  
  has_attached_file :collections_file, :dependent => :destroy_all#, :path => "private/files/collections/bulk_uploads_temp_files"

  def self.save_bulk_upload_xls_file(upload, upload_type)
    name = upload.original_filename
    directory = "private/files/#{upload_type}/bulk_uploads_temp_files"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(upload.read)}
  end

end
