#require 'molecular/primers/catalogs/action_panel'
#  module Molecular
#    module Primers
#      class Catalog < Templates::Catalog
#
#        def initialize options
#          options = {
#            columns: [
#
#              { :attribute => "name", :label => "Name", :width => 180 },
#              { :attribute => 'primer_target_organism.name', :label => 'Target Organism', width: 180 },
#              { :attribute => 'primer_gene.name', :label => 'Gene', width: 180 },
#              { :attribute => 'primer_purification_method.name', :label => 'Purification Method', :width => 180}
#            ]
#          }.merge!(options)
#          super
#          widgets({
#              action_panel: { init: ->{ Widgets::Molecular::Primers::Catalogs::ActionPanel.new({ parent: self, context: context }) }}
#            })
#        end
#      end
#    end
#  end

module Molecular
  module Primers
    class Catalog < Templates::Catalog
      def initialize options
        options = {
          columns: [
            { :attribute => "name", :label => "Name", :width => 180 },
            { :attribute => 'taxon.name', :label => 'Target Organism', width: 180 },
            { :attribute => 'marker.name', :label => 'Gene', width: 180 },
            { :attribute => 'purification_method.name', :label => 'Purification Method', :width => 180 }
          ]
        }.merge!(options)
        widgets({
          action_panel: { init: ->{ Molecular::Primers::Catalogs::ActionPanel.new( parent: self ) } }
        })
        super
      end
    end
  end
end

