require 'digest/sha1'
require 'authentication'
require 'scopes/with_project'

class User < Record
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

#  validates_presence_of     :login
#  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  #validates_format_of      :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BADT
#
#  validates_presence_of     :email
#  validates_length_of       :email,    :within => 6..100 #r@a.wk
#  #IMPORTANT - do not turn this on until we have addressed the issue of how old users in the system all have the same email
#  #validates_uniqueness_of  :email,    :case_sensitive => false
#  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates :password, :on => :create, :presence=>true
  validates :password_confirmation, :on => :create, :presence=>true
  validates :first_name, :presence=>true
  validates :last_name, :presence=>true
#  validates_presence_of :institution

  has_many :granted_roles
  has_many :role_types, :through => :granted_roles
  has_many :projects_from_roles, :through => :granted_roles, :source => :project
  has_many :changesets, :foreign_key => 'committer_id', :class_name => "Matrix::Changeset"

  has_many :taxa
  has_many :taggings
  has_many :tags, :through => :taggings
  has_many :workflows, :foreign_key => 'owner_id'

  has_many :role_member_users, primary_key: :rtid, foreign_key: :obj_rtid
  has_many :cells, class_name: 'Molecular::Matrix::Cell', foreign_key: 'responsible_user_id'
  has_many :otus, class_name: 'Otu', foreign_key: 'creator_id'

  has_many :issues
  has_many :project_user_requests
  before_create :make_activation_code
  after_save   :cascade_initials
  after_save   :cascade_name

#  belongs_to :person
#  accepts_nested_attributes_for :person

  scope :with_roles_in_project, lambda { |project|
    joins(:role_member_users).
    where(role_member_users: { owner_graph_rtid: project.rtid })
  }

  scope :with_min_rank_in_project, lambda { |rank, project_id| { :joins => :granted_roles,
    :conditions => ["role_type_id >= ? and granted_roles.project_id = ?", rank, project_id ] } }

  scope :for_projects, lambda { |projects| { :include => :granted_roles,
      :conditions => "granted_roles.project_id in (#{projects.collect{|p| p.id}.join(',')})" }}

  #TODO: need to check uniqueness of email on create

  def public_user?
    @is_public_user ||= (self == User.public_user)
  end

  def initials_label
    "#{initials} - #{first_name} #{last_name}"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def permissions
    Permission.
      joins(role: :role_member_users).
      where(role_member_users: { obj_rtid: self.rtid })
  end

  def logged_in?
    self != User.public_user
  end

  class << self
    def public_user
      admin_passkey.unlock(User).find_by_username('public')
    end
  end

  def validate_on_create
  end

#  delegate :enabled?, :username, :first_name, :last_name, :email, to: :vtattrs

  def vtattrs; vsattrs.vtattrs end # has_one through glitches here
  def login; username end#vattrs.username end
#  def enabled?; vattrs.enabled? end
#  def first_name; vattrs.first_name end
#  def last_name; vattrs.last_name end
#  def email; vattrs.email end

  def to_s
    "#{first_name} #{last_name}"
  end

  def pending_project_requests
    project_user_requests.find_all_by_status(ProjectUserRequest.pending)
  end

  # return all projects that a user is associated with through their current
  # roles - if user is admin, return an activerecord resource that provides
  # the equivalent of all projects tied to the admin
  def projects
    if(self.is_admin?)
      return Project.scope_all
    else
      return Project.for_user(self)
    end
  end

  def self.public_user_id
    user = self.public_user
    return user.user_id || fail('public user hasn\'t been defined in the database')
  end

  def self.public_user
    return self.find_by_username('public') || fail('public user hasn\'t been defined in the database')
  end

  def is_admin?
    admin_role = RoleType.find_by_name('administrator')
    has_admin_role = GrantedRole.find_by_user_id_and_role_type_id(self.id, admin_role.id)
    if(has_admin_role)
      return true
    else
      return false
    end
  end

  def is_manager?(project_id)
    has_role_in_project('manager', project_id)
  end
  alias_method :manages?, :is_manager?

  def is_updater_for? project
    is_updater? project.id
  end

  def is_updater?(project_id = nil)
    project_id ? has_role_in_project('updater', project_id) : has_role('updater')
  end

  # Activates the user in the database.
  def activate!
    @activated = true
    recently_activated= true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # deal with recpermissions later
  def can_edit? object
    self.owns?(object) || self.is_admin? || self.is_updater_for?(object.project)
  end

  def can_delete? object
    self.owns?(object) || self.is_admin? ||
      (self.is_updater_for? object.project && 
        (!object.respond_to?(:recpermission) || object.recpermission.name == 'Delete'))
  end

  def owns? object
    self == (object.respond_to?(:creator) && object.creator)
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(username_or_email, password)
    u = User.where(:username => username_or_email).first
    u || u = User.where(:email => username_or_email).first
    u && u.authenticated?(password) ? u : nil
  end

  def crypted_password
    self.attributes['password']
  end

  select_scope :full_name, {
    select: [ :first_name, :last_name ]
  }
  def full_name
    (first_name || "") + " " + (last_name || "")
  end

  select_scope :label, {
    select: [ :first_name, :last_name ]
  }
  def label
    full_name
  end

  def initials_name
    (initials ? (initials + " - ") : "") + full_name
  end

  def recently_activated?
    @_recently_activated = false
  end

  protected
    def recently_activated=(value)
      @_recently_activated = value
    end

    @_recently_activated = false

    def has_role(role)
      return true if self.is_admin?
      needed_role = RoleType.find_by_name(role)
      self.role_types.maximum(:rank) >= needed_role.rank
    end

    def has_role_in_project(role_name, project_id)
      return true if self.is_admin?
      has_role = RoleType.find_by_name(role_name)
      permission = self.granted_roles.find_by_project_id(project_id)
      user_role = permission ? permission.role_type : nil
     return(user_role ? (user_role.rank >= has_role.rank) : false)
  end

  def make_activation_code
      self.activation_code = self.class.make_token
  end

  def cascade_initials
    self.cells.each do |cell|
      unless cell.responsible_user_initials == self.initials
        cell.responsible_user_initials = self.initials
        cell.save
      end
    end
  end

  def cascade_name
    self.otus.each do |otu|
      unless otu.creator_name == self.name
        otu.creator_name = self.name
        otu.save
      end
    end
  end
end
