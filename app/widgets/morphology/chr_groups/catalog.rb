  module Morphology
    module ChrGroups
      class Catalog < Templates::Catalog

        def initialize options
          options = {
            columns: [
              { :attribute => "name", :width => 250 },
              { :attribute => "perspective", :width => 150 },
              { :attribute => "sensor", :width => 150 },
              { :attribute => "creator.label", :label => 'Owner', :width => 150 }
            ]
          }.merge!(options)
          widgets({
              action_panel: { init: ->{Morphology::ChrGroups::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
            })
          super
        end
      end
end
end
