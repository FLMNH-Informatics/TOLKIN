module Scopes
  module WithProject
    def self.extended(mod)
      mod.class_eval do
        scope :with_project, lambda{ |project|
          joins(:rsattrs).
          where(:rsattrs => { :owner_graph_rtid => project.rtid })
        }
      end
    end
  end
end
