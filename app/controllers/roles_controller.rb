require 'restful/responder'

class RolesController < ApplicationController
  include Restful::Responder

  def index
    super(passkey.unlock(Role))
  end

  def new
    super(passkey.unlock(Role))
  end

  def create

#    role = current_project.roles.create!
#    rsattrs = Rsattrs.create!(
#      :rtid => role.rtid,
#      :type_rtid => RecordClass.with_label('Role').first.rtid,
#      :owner_user_rtid => current_user.rtid,
#      :owner_graph_rtid => current_project.rtid,
#      :owner_permission_set => "i don't exist yet",
#      :creator_rtid => current_user.rtid,
#      :created_at => Time.now
#    )
#    debugger
#    redirect_to :back
  end

  def show
    super(passkey.unlock(Role))
  end
end