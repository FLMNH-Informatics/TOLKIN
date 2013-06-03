class Morphology::Matrix::Submatrix::SubmatrixOtus < ActiveRecord::Base
  self.table_name = "morphology_matrix_submatrix_characters"

  has_one :submatrix
  belongs_to :character
end