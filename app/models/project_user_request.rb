# To change this template, choose Tools | Templates
# and open the template in the editor.
class ProjectUserRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :updator, :class_name => 'User'
  
  def self.pending
   "pending"
  end
  def self.complete
  "complete"
  end
end
