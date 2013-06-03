class BulkUploadRecord < ActiveRecord::Base

  belongs_to :bulk_upload_filename

  def tolkin_record
    if self.is_taxon
      Taxon.where(:taxon_id => self.record_id).first
    else
      self.bulk_upload_filename.record_model.constantize.find(self.record_id)
    end
  end

  def record
    self.tolkin_record
  end

end