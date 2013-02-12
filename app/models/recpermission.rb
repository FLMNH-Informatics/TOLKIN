# == Schema Information
# Schema version: 20090423194502
#
# Table name: recpermissions
#
#  id   :integer         not null, primary key
#  name :string
#

class Recpermission < ActiveRecord::Base
  @view = "view"
  @edit = "edit"
  @delete = "delete"
  
  class << self
    attr_reader :view,:edit,:delete
  end

  def to_s
        self.name
  end
end
