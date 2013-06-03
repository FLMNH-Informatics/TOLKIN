class Morphology::Matrix::Submatrix::SubmatrixOtus < ActiveRecord::Base
  self.table_name = "morphology_matrix_submatrix_otus"

  has_one :submatrix
  belongs_to :otu
end