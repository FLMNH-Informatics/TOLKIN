class Basic::User < ActiveRecord::Base
  #include Authentication
  #include Authentication::ByPassword
  #include Authentication::ByCookieToken

  self.table_name = 'users'
  self.primary_key = 'user_id'

  validates_uniqueness_of   :username, :case_sensitive => false

  #validates_format_of      :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BADT
  #
  #  validates_presence_of     :email
  #  validates_length_of       :email,    :within => 6..100 #r@a.wk
  #  #IMPORTANT - do not turn this on until we have addressed the issue of how old users in the system all have the same email
  #  #validates_uniqueness_of  :email,    :case_sensitive => false
  #  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  #validates :password, :on => :create, :presence=>true
  #validates :password_confirmation, :on => :create, :presence=>true
  validates :first_name, :presence=>true
  validates :last_name, :presence=>true

  has_many :granted_roles, :class_name => 'Basic::GrantedRole'
  has_many :projects, :class_name => 'Basic::Project' , :through => :granted_roles

  def login; username end
end