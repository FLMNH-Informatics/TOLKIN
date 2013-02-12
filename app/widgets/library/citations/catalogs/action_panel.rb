module Library
  module Citations
    module Catalogs
      class ActionPanel < Templates::ActionPanel
        def initialize options
          @buttons ||= [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Bulk Upload', img: { src: "/images/sm_upload.png" }, imode: 'edit'},
            { label: 'Citations Search', img: { src: "/images/small_search.png" }, imode: [ 'edit', 'browse' ] }
          ]
          super
        end

        #  def to_s
        #    render partial: 'library/citations/catalogs/action_panel'
        #  end
      end
    end
  end
end
