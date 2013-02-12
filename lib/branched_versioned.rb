module BranchedVersioned

  #TODO we might want to ask a branch to create a newer version for us instead of asking a characters
  def create_new_version(params_hash,new_branch = false) #branch_id
    #branch = branches.collect{|temp_branch| temp_branch.id == branch_id}.compact.first
    raise "Multiple Branches, Please pass new_branch parameter explicitly" if branches.size > 1 && !new_branch
    Matrix::BranchItem.transaction do
      branch = (!new_branch && branches.first) || object_history.new_branch
      new_obj = self.create_clone
      params_hash.each do |key, val|
        new_obj.attributes = params_hash
      end
      new_obj.save!
      br_items_br = Matrix::BranchItemsBranch.new(:branch => branch, :branch_item => Matrix::BranchItem.new(:item => new_obj), :position => branch.max_position + 1)
      branch.save!
      br_items_br.save!
    end
    true
  end

  def branches
    self.branch_item.branches
  end

  def object_history
    self.branch_item.branches.first.object_history
  end

  def history
    object_history
  end

  def branch
    branch_item.branches.find(:first, :order => "branch_number DESC", :limit => 1)
  end

  def branch_position
    branch_items_branches = Matrix::BranchItemsBranch.find_by_branch_item_id_and_branch_id(branch_item.id, branch.id) if branch && branch_item
    branch_items_branches.try(:position)
  end

  def branch_position_for(for_branch)
    branch_items_branches = Matrix::BranchItemsBranch.find_by_branch_item_id_and_branch_id(branch_item.id, for_branch.id) if branch_item
    branch_items_branches.try(:position)
  end

  #need to overwrite this in model classes
  def create_clone
    raise "Overwrite me!"
  end
end