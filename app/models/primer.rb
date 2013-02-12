# == Schema Information
# Schema version: 20090423194502
#
# Table name: primers
#
#  id          :integer(8)      not null, primary key
#  name        :string          not null
#  description :string
#  sequence    :string
#  created_at  :date            not null
#  creator_id  :integer(8)      not null
#  updated_at  :date            not null
#  updator_id  :integer(8)      not null
#  guid        :string          not null
#  project_id  :integer(8)      not null
#

class Primer < ActiveRecord::Base
  belongs_to :project
end
