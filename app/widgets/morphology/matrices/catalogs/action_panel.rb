require 'templates/action_panel'

  module Morphology
    module Matrices
      module Catalogs
        class ActionPanel < Templates::ActionPanel
          def initialize options
            @buttons ||= [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Import Matrix', img: { src: "/images/small_import.png" }, imode: 'edit' },
            { label: 'Modify Matrix', img: { src: "/images/small_edit.png" }, imode: 'edit' },
            { label: 'Export Nexus file', img: { src: "/images/sm_upload.png" }, imode: 'edit' }
            #{ label: 'Merge Matrix', img: { src: "/images/small_merge.png" }, imode: 'edit' },
            #{ label: 'Designate Submatrix', img: { src: "/images/small_submatrix.png" }, imode: 'edit' }
          ]
            super
          end

#          def to_s
#            render partial: 'morphology/matrices/catalogs/action_panel'
#          end
        end
      end
    end
  end
