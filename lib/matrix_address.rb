class MatrixAddress

  attr_accessor(:object_history_id, :branch_number, :branch_position)

  def initialize(object_history_id, branch_number, branch_position)
    @object_history_id, @branch_number, @branch_position = object_history_id, branch_number, branch_position
  end

  def self.from_branch_info(branch, branch_position)
    self.new(branch.object_history.id, branch.branch_number, branch_position.to_i)
  end

  def self.from_s(address)
    object_history_id, branch_number, branch_position = address.split("-").collect {|x| x.to_i }
    raise "address value given is less than or equal to zero" if object_history_id <= 0 || branch_number <= 0 || branch_position < 0
    MatrixAddress.new(object_history_id, branch_number, branch_position)
  rescue => e
    raise "Problem encountered creating matrix address object from string: #{e.message}"
  end

  def object_history
    ObjectHistory.find(object_history_id)
  end

  def branch
    object_history = ObjectHistory.find(object_history_id)
    object_history.branches.find_by_branch_number(branch_number)
  rescue
    raise "Branch could not be found"
  end

  def to_s
    @object_history_id.to_s + "-" + @branch_number.to_s + "-" + @branch_position.to_s
  end

  def next_address_if_exists
    next_address = MatrixAddress.new(@object_history_id, @branch_number, @branch_position + 1)
    MatrixAddress.exists?(next_address) ? next_address : nil
  end

  def previous_address_if_exists
    prev_address = MatrixAddress.new(@object_history_id, @branch_number, @branch_position - 1)
    MatrixAddress.exists?(prev_address) ? prev_address : nil
  end

  def is_valid?
    MatrixAddress.exists?(self)
  end

  def self.exists?(address)
    object_history, branch, branch_item = nil
    object_history = ObjectHistory.find(address.object_history_id)
    branch = object_history.branches.find_by_branch_number(address.branch_number) if object_history
    branch && address.branch_position >= 0 && address.branch_position <= branch.branch_items_branches.maximum(:position) ? true : false
  rescue ActiveRecord::RecordNotFound
    false
  end


end
