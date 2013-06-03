class Morphology::Matrix::Submatrix < ActiveRecord::Base

  belongs_to :timeline, :class_name => "Morphology::Matrix::Timeline"

  has_many :submatrix_otus, :class_name => "Morphology::Matrix::Submatrix::SubmatrixOtus", :foreign_key => :submatrix_id
  has_many :otus, :through => :submatrix_otus

  has_many :submatrix_characters, :class_name => "Morphology::Matrix::Submatrix::SubmatrixCharacters", :foreign_key => :submatrix_id
  has_many :characters, :through => :submatrix_characters

  validates :name, :uniqueness => { :scope => :timeline }
  validates :name, :presence => true
  default_scope :order => 'name'

end