class AdvancedSearch < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :project
    scope :for_model_by_project, lambda { |model_name, project_id, limit| { :conditions => ["model = ? and project_id = ? ", model_name , project_id], :order => "created_at DESC" , :limit => limit} }
end
