module Library
  module Citations
    class Catalog < Templates::Catalog
      def initialize options
        options = {
          columns: [
            { attribute: "authors_joined", label: 'Authors', width: 200 },
            { attribute: "year",   width: 50 },
            { attribute: "title",  width: 350 },
            { attribute: "publication.value", label: 'Publication', width: 150 }
          ]
        }.merge!(options)
        widgets({
            action_panel: { init: ->{Library::Citations::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
          })
        super
      end
    end
  end
end
