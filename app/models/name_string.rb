# == Schema Information
# Schema version: 20090423194502
#
# Table name: name_strings
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class NameString < ActiveRecord::Base
  #FIXME referring to classes that are no longer there. Speak to Srinivas about this.
  has_many :citations, :through => :citation_name_strings
  has_many :citation_name_strings
  has_many :people, :through => :pen_names
  has_many :pen_names

  def to_param
    param_name = name.gsub(" ", "_")
    param_name = param_name.gsub(/[^A-Za-z0-9_]/, "")
    "#{id}-#{param_name}"
  end

  def solr_id
    "NameString-#{id}"
  end
  
  #return what looks to be the last name in this name string
  def last_name
    names = self.name.split(',')
    names[0]
  end
end
