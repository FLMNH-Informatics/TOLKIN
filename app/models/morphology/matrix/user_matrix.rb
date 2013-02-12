# standard matrix after its been processed with current user changeset.
# After modifying x_items, y_items, and cells, UserMatrix just decorates
# standard matrix.
class Morphology::Matrix::UserMatrix

  attr_reader :changeset

  def initialize matrix, changeset
    @matrix = matrix
    @changeset = changeset
    @changeset.filter_matrix matrix
  end

  def self.for_address_and_user address, user, options = { }
    matrix = Morphology::Matrix.for_address address, options
    changeset = Changeset.for_matrix_and_user matrix, user
    self.new matrix, changeset
  end

  def to_param
    @matrix.address.to_s
  end

  def method_missing method, *args
    args.empty? ? @matrix.try(method) : @matrix.try(method, *args)
  end
end
