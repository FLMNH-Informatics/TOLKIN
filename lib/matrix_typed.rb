module MatrixTyped

  def self.included receiver
    receiver.extend ClassMethods
  end

  def checkpoints
    self.branch.try(:checkpoints) || [ ]
  end

  def name
    @name || self.branch.try(:name)
  end

  def description
    @description || self.branch.try(:description)
  end

  def creator
#    @creator || self.branch.try(:creator)
  end

  def project
    @project || self.branch.try(:project)
  end

  def branch
    address.try(:branch)
  end

  def version_number
    address.try(:branch_position)
  end

  def parent
    @parent || self.try(:branch).try(:parent)
  end

  def updater
#    previous_changeset.try(:committer)
  end

  def created_at
    branch.try(:created_at)
  end

  def updated_at
    previous_changeset.try(:committed_at)
  end

  def previous_changeset
    address && branch ? branch.changesets.committed.find_by_changeset_number(address.branch_position - 1) : nil
  end

  module ClassMethods
    def for_matrix_address(matrix_address, options = { })
      options = { :retrieve_cells => true }.merge options
      
      branch, branch_position = matrix_address.branch, matrix_address.branch_position
      checkpoint = branch.branch_items_branches.find(:first, :order => "abs(position - #{branch_position}) ASC" ).branch_item.item
      matrix = self.new :address => Matrix::Address.from_branch_info(branch, checkpoint.branch_position_for(branch))
      matrix.x_items, matrix.y_items, matrix.cells = checkpoint.get_contents(options)

      #TODO check that copy to matrix is working properly
      if matrix.version_number > branch_position
        branch.committed_changeset(branch_position).step_before_changes matrix
      elsif matrix.version_number < branch_position
        branch.committed_changeset(branch_position - 1).step_after_changes matrix
      end

      # if there isn't a checkpoint at current location then characters haven't been paginated yet
      if options[:page] && checkpoint.branch_position_for(branch) != branch_position
        matrix.x_items = matrix.x_items.paginate(:page => options[:page], :per_page => 15)
      end
      matrix
    end
  end
end