class Migration::AbstractLegacyRecord < ActiveRecord::Base
  establish_connection "tolkin1_database"
  self.abstract_class = true
end