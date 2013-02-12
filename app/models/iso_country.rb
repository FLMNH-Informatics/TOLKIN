class IsoCountry < ActiveRecord::Base
  has_many :collections, :class_name => "Collection"

  self.table_name = 'countries'
end