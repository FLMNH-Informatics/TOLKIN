class Migration::SeqInfo < Migration::AbstractLegacyRecord
  self.table_name = 'seq_info'
  self.primary_key = 'seq_id'
end