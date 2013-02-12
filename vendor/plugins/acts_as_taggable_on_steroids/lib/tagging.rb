class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :user

  #before_save :use_user_id
  
  def after_destroy
    if Tag.destroy_unused
      if tag.taggings.count.zero?
        tag.destroy
      end
    end
  end
  


protected
def use_user_id
  #
  #AuthenticatedSystem::logged_in?
  self.user_id = session[:user_id]
end

end
