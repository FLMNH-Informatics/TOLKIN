# adds currently selected project to current item being saved
class ProjectStamper < ActiveRecord::Observer
  observe Image,
    Collection,
    Library::Citation,
    #::Matrix::Branch,
    Molecular::Alignment,
    Molecular::Insd::Seq,
    Molecular::Matrix,
    Molecular::Matrix::Cell,
    #Molecular::Matrix::Checkpoint,
    Molecular::Primer,
    Morphology::Character,
    Morphology::ChrGroup,
    Morphology::Matrix,
    Morphology::Matrix::Checkpoint,
    Morphology::StateCoding,
    Otu,
    OtuGroup,
    Permission,
    PermissionSet,
    Taxon,
    Chromosome::Dye,
    Chromosome::ZFile,
    Chromosome::Probe

  attr_accessor(:project)

  def before_create(item)
    case item.class.to_s
    when 'Taxon', 'Permission', 'PermissionSet'
      item.owner_graph_rtid = project.rtid
    else
      item.project_id = project.id if item.methods.include?(:project_id)
    end
  end
end
