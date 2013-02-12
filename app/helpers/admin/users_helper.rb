module Admin::UsersHelper

  def roles_list
    roles = {}
    RoleType.all.each do |role|
      roles[role.rank] = role.name
    end
    roles
  end

  def roles_options
    output = ''
    roles_list.each do |rank,name|
       output << "<option value=\"#{rank}\" >#{name}</option>" unless name.downcase == 'administrator'
    end
    raw output
  end
end