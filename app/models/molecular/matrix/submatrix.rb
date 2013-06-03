class Molecular::Matrix::Submatrix < ActiveRecord::Base

  belongs_to :timeline, :class_name => "Molecular::Matrix::Timeline"

  has_many :submatrix_otus, :class_name => "Molecular::Matrix::Submatrix::SubmatrixOtus", :foreign_key => :submatrix_id, :order => "position"
  has_many :otus, :through => :submatrix_otus, :order => "position"


  has_many :submatrix_markers, :class_name => "Molecular::Matrix::Submatrix::SubmatrixMarkers", :foreign_key => :submatrix_id, :order => "position"
  has_many :markers, :through => :submatrix_markers, :order => "position"


  validates :name, :uniqueness => { :scope => :timeline }
  validates :name, :presence => true
  default_scope :order => 'name'

end