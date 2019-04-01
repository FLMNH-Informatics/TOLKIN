require 'user'

class UserSignature < ActiveRecord::Observer
  observe(
      Collection,
      Library::Publication,
      Molecular::Alignment,
      Molecular::Insd::Seq,
      Molecular::Matrix::Cell,
      Molecular::Matrix::Timeline,
      Molecular::Matrix,
      Molecular::Marker,
      Molecular::Primer,
      Morphology::Character,
      Morphology::ChrGroup,
      Morphology::ChrState,
      Morphology::StateCoding,
      Morphology::Matrix,
      Morphology::Matrix::Timeline,
      Morphology::Matrix::Cell,
      OtuGroup,
      Otu,
      Permission,
      PermissionSet,
      Taxon,
      Chromosome::ZFile
  )

  attr_accessor(:user)

  def before_create(item)
 
    case item.class.to_s
      when 'Chromosome::ZFile'
        item.user_id = user.id
      when 'Matrix::Changeset'
        item.committer_id = user.id
      when 'Matrix::Branch', 'OtuBranch', 'Morphology::CharacterBranch', 'Morphology::StateCoding',
           'Molecular::Matrix::Cell', 'Molecular::Marker', 'Morphology::Matrix::Cell', 'Morphology::Matrix'
        item.creator_id = user.id if item.creator_id.nil?
      when 'Library::Publication'
        item.creator_id = user.id if item.creator_id.nil?
       # item.updator_id = user.id if item.updator_id.nil?
      when 'Otu', 'Morphology::Character', 'Morphology::ChrState', 'Morphology::ChrGroup', 'OtuGroup'
        item.creator_id = user.id if item.creator_id.nil?
        item.updator_id = user.id if item.updator_id.nil?
      when 'Taxon', 'Permission', 'PermissionSet'
        item.owner_user_rtid = user.rtid
        item.creator_rtid = user.rtid
        item.updater_rtid = user.rtid
      when 'Collection'
        item.user_id = user.id
        item.last_updated_by = user.id
      else
        item.creator_id = user.id if item.methods.include?(:creator_id)
        item.updater_id = user.id if item.methods.include?(:updater_id)
    end
  end

  def before_update(item)
    case item.class.to_s
    when 'Chromosome::ZFile'
      item.user_id = user.id if item.methods.include?(:user_id)
    when 'Matrix::Changeset', 'Matrix::Branch', 'OtuBranch', 'Morphology::CharacterBranch', 'Morphology::StateCoding',
         'Molecular::Matrix::Cell', 'Molecular::Marker'
    when 'Morphology::Character', 'Otu', 'Morphology::ChrState', 'Morphology::ChrGroup', 'OtuGroup'
      item.updator_id = user.id if item.methods.include?(:updator_id)
    when 'Morphology::Matrix'
      item.updater_id = user.id if item.methods.include?(:updater_id)
    when 'Taxon', 'Permission', 'PermissionSet'
      item.updater_rtid = user.rtid if item.methods.include?(:updater_rtid)
    when 'Collection'
      item.last_updated_by = user.id if item.methods.include?(:last_updated_by)
    when 'Library::Publication'
      # do nothing
    else
      item.updater_id = user.id if item.methods.include?(:updater_id)
    end
  end
end
