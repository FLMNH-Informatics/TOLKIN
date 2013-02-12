# == Schema Information
# Schema version: 20090423194502
#
# Table name: bookmarks
#
#  id  :integer         not null, primary key
#  url :string
#

class Bookmark < ActiveRecord::Base
  acts_as_taggable


  def display_attr_val     # a reader
    self.url
  end
  
end
