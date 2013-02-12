require 'templates/catalog'
require 'library/publications/catalogs/action_panel'
  module Library
    module Publications
      class Catalog < Templates::Catalog

        def initialize options
          options = {
            columns: [
              { :attribute => "name", :width => 500 }
            ]
          }.merge!(options)
          widgets({
              action_panel: { init: ->{Widgets::Library::Publications::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
            })
          super
        end
      end
    end
  end
