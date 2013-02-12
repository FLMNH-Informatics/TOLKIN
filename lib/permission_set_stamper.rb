# adds currently selected project to current item being saved
class PermissionSetStamper < ActiveRecord::Observer
  observe (
    Taxon
  )

  attr_accessor(:project)

  def before_create(item)
    item.owner_permission_set_rtid = project.default_permission_set.rtid
  end
end
