class Migration::Collection < Migration::AbstractLegacyRecord
  self.table_name = 'collections'
  self.primary_key = "col_id"
end
