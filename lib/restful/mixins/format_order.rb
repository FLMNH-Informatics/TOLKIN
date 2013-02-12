module Restful
  module Mixins
    module FormatOrder
      def format_order
        @out[:order] = [*@input[:order]].inject([]) do |acc,select|
          acc << _alias_order(select, @model_class)
          acc
        end.join(',')
      end

      def _alias_order attr, model, assoc_path = nil
        if(attr.match(/^\s*(\w+)\.((\w+)(\s+\w+)?)\s*$/))
          _alias_order(
            $2,
            (model && model.reflect_on_association($1.to_sym).try(:klass)),
            [ assoc_path, $1 ].compact.join('.')
          )
        else
          attr.match(/^\s*(\w+)(\s+\w+)?\s*$/)
          if(model && model.columns_hash[$1])
            "#{@assoc_path_to_aliases[assoc_path]}.#{$1}#{$2}"
          else
            nil
          end
        end
      end
    end
  end
end