require 'templates/catalog'
  module Taxa
    class CollectionsCatalog < Templates::Catalog
      def initialize options
        @columns = [
          { attribute: :collector        , width: 100 },
          { attribute: :collection_number, width: 100 },
          { attribute: :country          , width: 100 },
          { attribute: :institution_code , width: 100 }
        ]
        @collection = options[:taxon].collections
        @limit = 10
        @has_filter_set = false
        super
      end
    end
  end
