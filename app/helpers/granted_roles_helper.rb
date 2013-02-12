module GrantedRolesHelper
  def assigned_roles_heading
    if(@user.granted_roles.count.zero?)
      heading = "<tr><td>No roles assigned</td></tr>"
    else
      heading = "<tr><th>Role</th><th>Project</th></tr>"
    end

    heading
  end

  # takes care of nil project in the case of admin role
  def print_role_project_name(role)
    out_str = ""
    out_str << role.project.name if role.project
  end
end