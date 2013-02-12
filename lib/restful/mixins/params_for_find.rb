module Restful
  module Mixins
    module ParamsForFind
      def params_for_find model_class
        params[:select] = params[:only] if params[:only]
        params[:page] = 1 unless params[:page]
        formatter = Restful::Finder::OptionFormatter.new(model_class: model_class, collection: @collection)
        parsed, @collection = formatter.format(params)
        parse_for_paginate parsed
      end

      def parse_for_paginate so_far
        parsed = so_far
        if so_far[:limit]
          so_far[:offset] ||= 0
          parsed[:per_page] = so_far[:limit].to_i
          parsed[:page] = (so_far[:offset].to_i / so_far[:limit].to_i) + 1
        end
        parsed.delete(:offset) && parsed.delete(:limit)
        parsed
      end
    end
  end
end
