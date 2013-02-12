require 'acts_as_habtm_list'

ActiveRecord::Base.class_eval do
  include RailsExtensions::Acts::HabtmList
end
