  module Morphology
    module Characters
class Catalog < Templates::Catalog

  def initialize options
    options = {
      columns: [
        { :attribute => "name", :width => 250 },
        { :attribute => "short_name", :width => 250 },
        { :attribute => "chr_groups_joined", :label => "Character Groups", :map => 'name', :width => 250 },
        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
      ]
    }.merge!(options)
    widgets({
        action_panel: { init: ->{Morphology::Characters::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
      })
    super
  end

  def column_value(item, column)
    if column[:attribute] == 'chr_groups'
      return item.characters_chr_groups.inject('') do |acc, characters_chr_groups_entry|
        return acc+characters_chr_groups_entry.chr_group.name
      end
    else
      return nested_attribute(item, column[:attribute])
    end
  end
end
end
end
