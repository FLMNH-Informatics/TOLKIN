class BulkUploadFilename < ActiveRecord::Base
  belongs_to :project
  has_many :bulk_upload_records

  def records
    self.bulk_upload_records.map{|rec| rec.tolkin_record }
  end

  def tolkin_records
    self.records
  end

  def taxa_records
    Taxon.where(:taxon_id => self.bulk_upload_records.where(:is_taxon => true).map{|r|r.record_id})
  end

end