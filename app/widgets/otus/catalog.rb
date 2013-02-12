module Otus
  class Catalog < Templates::Catalog

    def initialize options = {}
      options = {
        columns: [
          { :attribute => "name", :width => 250 },
          { :attribute => "otu_groups_joined", :width => 200 },
          { :attribute => "creator.label", :label => 'Owner', :width => 150 }
        ],
      }.merge!(options)
      widgets({
          action_panel: { init: ->{Otus::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
        })
      super
    end

    def column_value(item, column)
      if column[:attribute] == 'otu_groups'
        return item.otu_groups.collect(&:name).join(', ')
        #          return item.otu_groups_otus.inject('') do |acc, otu_groups_otus_entry|
        #            return acc+otu_groups_otus_entry.otu_group.name
        #          end
      else
        return nested_attribute(item, column[:attribute])
      end
    end
  end
end