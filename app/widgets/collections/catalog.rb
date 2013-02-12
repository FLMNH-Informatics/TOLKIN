  require 'collections/catalogs/action_panel'
  require 'collections/catalogs/filter_set'
  module Collections
    class Catalog < Templates::Catalog

    def initialize options
      options = {
        columns: [
          { attribute: "collector", width: 100 },
          { attribute: "collection_number", label: "Collection Number", width: 100 },
          { attribute: "taxon.label", label: "Taxon", width: 300 },
          { attribute: "country", width: 100 }
        ],
      }.merge!(options)
      widgets({
        action_panel: { init: ->{ Collections::Catalogs::ActionPanel.new(parent: self, context: options[:context])} },
        filter_set:   { init: ->{ Collections::Catalogs::FilterSet.new({ parent: self, context: context, catalog: self })
        }}
      })
      super
    end
   end
 end