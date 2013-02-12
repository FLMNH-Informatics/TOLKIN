class LengthUnit < ActiveRecord::Base
  self.table_name = 'lengthunits'

  def to_s
    name
  end

  def label
    self.name
  end
end
