module TagsHelper
  def route_helper(obj)
    if obj.is_a?(Morphology::ChrState)
      "/projects/#{obj.character.project_id}/characters/#{obj.character_id}/#{obj.class.to_s.demodulize.tableize}/#{obj.id}"
    elsif obj.is_a?(Matrix::Branch)#presuming morpholgy matrix branch
      project_matrix_path(obj.project_id, obj.max_address)
    elsif obj.is_a?(Morphology::StateCoding)
      "/projects/#{obj.matrix.project_id}/matrices/#{obj.matrix_id}"
    else
      "/projects/#{obj.project_id}/#{obj.class.to_s.demodulize.tableize}/#{obj.id}"
    end
  end
end

#module TagsHelper
#  def route_helper(tagging, user)
#    if !tagging.taggable_type.constantize == Matrix::UserMatrix
#      obj = tagging.taggable_type.constantize.find(tagging.taggable_id)
#      if obj.is_a?(Morphology::ChrState)
#        link_str = "/projects/#{obj.character.project_id}/characters/#{obj.character_id}/#{obj.class.to_s.demodulize.tableize}/#{obj.id}"
#      elsif obj.is_a?(Morphology::StateCoding)
#        link_str  = "/projects/#{obj.matrix.project_id}/matrices/#{obj.matrix_id}"
#      elsif( obj.is_a?(Library::Journal)|| obj.is_a?(Library::Book) || obj.is_a?(Library::BookSection) || obj.is_a?(Library::Others))
#        link_str = "/projects/#{obj.project_id}/citations/#{obj.id}"
#      else
#        link_str = "/projects/#{obj.project_id}/#{obj.class.to_s.demodulize.tableize}/#{obj.id}"
#      end
#      link_to link_str, link_str
#    else
#      project_matrix_path Matrix::UserMatrix.for_address_and_user(Matrix::Address.from_s(tagging.taggable_id), user), Matrix::Address.from_s(tagging.taggable_id)
#    end
#  end
#end
