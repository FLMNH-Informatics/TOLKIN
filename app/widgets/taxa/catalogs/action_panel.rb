require 'templates/action_panel'
  module Taxa
    module Catalogs
      class ActionPanel < Templates::ActionPanel
        def initialize options
          @buttons ||= [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Export', img: { src: "/images/small_report.png" }, imode: [ 'browse', 'edit' ] },
            { label: 'Set Permissions', imode: 'edit' }
          ]
          super
        end
      end
    end
  end

