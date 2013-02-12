# == Schema Information
# Schema version: 20090423194502
#
# Table name: predicates
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  description :string(255)
#

class Predicate < ActiveRecord::Base
   acts_as_taggable
end
