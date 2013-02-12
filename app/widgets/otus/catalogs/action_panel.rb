  module Otus
    module Catalogs
      class ActionPanel < Templates::ActionPanel


        def initialize options
          @buttons ||= [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Add to OTU Group', img: { src: "/images/small_arrow.png" }, imode: 'edit' },
            { label: 'Export', img: { src: "/images/small_report.png" }, imode: ['browse','edit'] }
          ]
          super
        end

#        def to_s
#          render partial: 'otus/catalogs/action_panel'
#        end
      end
    end
  end
