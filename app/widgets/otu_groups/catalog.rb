module OtuGroups
  class Catalog < Templates::Catalog

    def initialize options = {}
      options = {
        columns: [
          { :attribute => "name", :width => 250 },
          { :attribute => "creator.label", :label => 'Owner', :width => 150 }
        ],
      }.merge!(options)
      widgets({
          action_panel: { init: ->{OtuGroups::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
        })
      super
    end
  end
end