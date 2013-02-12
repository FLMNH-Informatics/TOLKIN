class Migration::Taxonomy < Migration::AbstractLegacyRecord
  self.table_name = 'taxonomy'
  self.primary_key = "tax_id"

  belongs_to :project, :class_name => 'Migration::Project', :foreign_key => 'project'
end
