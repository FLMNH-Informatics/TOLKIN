class Morphology::Matrices::Catalog < Templates::Catalog
  def initialize options
    @data_id ||= :id
    options = {
      columns: [
        { :attribute => "name",                                    :width => 250 },
        { :attribute => "description",                             :width => 150 },
        { :attribute => "copied_from",                             :width => 150 },
        { :attribute => "created_by",                              :width => 90 },
        { :attribute => "created_at",                              :width => 150 },
        { :attribute => "updated_by",    :label => 'Last Updater', :width => 90 },
        { :attribute => "updated_at",    :label => 'Last Update',  :width => 150 }
      ]
    }.merge!(options)
    widgets({
      action_panel: { init: ->{Morphology::Matrices::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }#,
    })
    super
  end
end





#require 'templates/catalog'
#require 'morphology/matrices/catalogs/action_panel'
#  module Morphology
#    module Matrices
#      class Catalog < Templates::Catalog
#
#        def initialize options = {}
#          @data_id ||= :matrix_id
#          options = {
#            columns: [
#              { attribute: "name",                                 width: 250 },
#              { attribute: "description",                          width: 150 },
#              { attribute: "parent.name",   label: 'Submatrix of', width: 250 },
#              { attribute: "updater_label", label: 'Last Updator', width: 100 },
#              { attribute: "updated_at",    label: 'Last Update',  width: 150 },
#              { attribute: "creator.label", label: 'Owner',        width: 100 },
#              { attribute: "created_at",    label: 'Created',      width: 150 }
#            ],
#          }.merge!(options)
#           widgets({
#            action_panel: { init: ->{Morphology::Matrices::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
#          })
#          super
#        end
#
#      #  collectionClass: { is: 'ro', init: function () { return Models.Matrices.Branch } },
#      #      collectionName: { init: 'matrix::branch' },
#      #      columns: { init: function () {  }}
#      end
#    end
#  end
#
