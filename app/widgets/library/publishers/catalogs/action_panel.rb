  module Library
    module Publishers
      module Catalogs
        class ActionPanel < Templates::ActionPanel


          def initialize options
            @buttons = {}
            super
          end

          def to_s
            render partial: 'library/publishers/catalogs/action_panel'
          end
        end
      end
    end
  end
