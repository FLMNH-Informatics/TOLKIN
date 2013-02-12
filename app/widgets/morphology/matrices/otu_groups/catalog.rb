class Morphology::Matrices::OtuGroups::Catalog < Templates::Catalog
  def initialize options
    options = {
      columns: [
        { :attribute => "otu_group.name",      :label => 'Otu Group',   :width => 250 },
        { :attribute => "color",         :label => 'Color',         :width => 100 },
        { :attribute => "creator",    :label => 'Added By',      :width => 150 }
      ]
    }.merge!(options)
    super
    widgets({
      action_panel: { init: ->{ Widgets::Morphology::Matrices::OtuGroups::Catalogs::ActionPanel.new({ parent: self, context: context }) }}
    })
  end
end