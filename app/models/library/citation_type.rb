# == Schema Information
# Schema version: 20090423194502
#
# Table name: citation_types
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  user_id     :integer
#

class Library::CitationType < ActiveRecord::Base
        
end
