# == Schema Information
# Schema version: 20090423194502
#
# Table name: marked_records
#
#  type       :string          not null
#  type_id    :integer         not null
#  created_at :datetime        not null
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#

class MarkedRecord < ActiveRecord::Base
       #classNames = { {"className"=>"Taxon"},{ "className"=>"Collections"}}
       def MarkedRecord.class_names
          ["Taxon", "Collection"]
       end
end
