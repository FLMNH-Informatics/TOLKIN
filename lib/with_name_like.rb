module WithNameLike
  def self.included(base)
    base.class_eval do
      scope :with_name_like, lambda { |match|
        { :conditions => ["lower(name) like lower(?)", match ] }
      }
    end
  end
end
