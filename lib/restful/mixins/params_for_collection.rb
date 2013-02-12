
require 'restful/options/collection_initial_options'
require 'restful/options/collection_limited_options'
module Restful
  module Mixins
    module ParamsForCollection

      def collection_initial_options model_class
        formatter = Restful::Options::CollectionInitialOptions.new(model_class: model_class, collection: @collection)
        parsed, @collection = formatter.format(params)
        parsed
      end

      def collection_limited_options(model_class, ids = nil)
        optioner ||= Restful::Options::CollectionLimitedOptions.new(model_class: model_class, collection: @collection, ids: ids)
        optioner.options_from(params)
      end

    end
  end
end