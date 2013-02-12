module Molecular
  module Alignments
    module Catalogs
      class ActionPanel < Templates::ActionPanel
        def initialize options
          @buttons ||= [
            #{ label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' }
          ]
          super
        end
        #  def to_s
        #    render partial: 'molecular/alignments/catalogs/action_panel'
        #  end
      end
    end
  end
end
