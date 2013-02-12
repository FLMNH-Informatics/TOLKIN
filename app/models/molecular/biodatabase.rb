# == Schema Information
# Schema version: 20090717175815
#
# Table name: biodatabase
#
#  biodatabase_id :integer         not null, primary key
#  name           :string(128)     not null
#  authority      :string(128)
#  description    :text
#

class Molecular::Biodatabase < ActiveRecord::Base
  self.table_name = "biodatabase"
  self.primary_key = "biodatabase_id"

  has_many :bioentry, :class_name => "Molecular::Bioentry"
end
