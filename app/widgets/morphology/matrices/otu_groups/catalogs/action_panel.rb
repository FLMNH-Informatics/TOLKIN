class Morphology::Matrices::OtuGroups::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    @buttons = {} 
    super
  end

  def to_s
    render partial: 'morphology/matrices/otu_groups/catalogs/action_panel'
  end
end
