class Permission < Record
  belongs_to :role, :primary_key => :rtid, :foreign_key => :role_rtid
#  has_many :member_users, through: :role

  def self.name_for_action action
    case action.to_s
      when 'view', 'see'
        :visible
      when 'edit', 'update'
        :editable
      when 'delete'
        :deletable
      when 'permit'
        :permissible
      else fail "unknown action name"
    end
  end

  scope :permits, lambda { |user, options = {}|
    self.
      joins({
        role: :role_member_users
      }).
      where({
        Permission.name_for_action(options[:to]) => true,
        role: {
          role_member_users: { obj_rtid: user.rtid }
        }
      })
  }
end