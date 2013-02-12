#  module Molecular
#    module Primers
#      module Catalogs
#        class ActionPanel < Templates::ActionPanel
#
#          def to_s
#            render partial: 'molecular/primers/catalogs/action_panel'
#          end
#        end
#      end
#    end
#  end

 class Molecular::Primers::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    @buttons = [
      { label: 'New', img: { src: '/images/small_addnew.gif' }, imode: 'edit' },
      { label: 'Delete', img: { src: '/images/small_cross.png' }, imode: 'edit'}
    ]
    super
  end
end
