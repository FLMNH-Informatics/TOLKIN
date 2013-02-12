class Migration::User < Migration::AbstractLegacyRecord
  self.primary_key = 'user_id'
end
