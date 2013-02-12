class Chromosome::Hybridization < ActiveRecord::Base

  belongs_to :dye
  belongs_to :z_file
  belongs_to :probe
  
end