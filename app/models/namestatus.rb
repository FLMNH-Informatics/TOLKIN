# == Schema Information
# Schema version: 20090423194502
#
# Table name: namestatuses
#
#  id          :integer         not null, primary key
#  status      :string(255)     not null
#  description :string(255)
#

class Namestatus < ActiveRecord::Base
  default_scope :order => :id
        #acts_as_taggable

  composite :label, [ :status ]
  def label
    status.humanize
  end

  def to_s
    status
  end

end
