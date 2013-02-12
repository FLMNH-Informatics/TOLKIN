class Migration::RawDna < Migration::AbstractLegacyRecord
  self.table_name = 'raw_dna'
  self.primary_key = "raw_id"
end
