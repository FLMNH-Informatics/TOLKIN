module Restful
  module Mixins
    module FormatConditions
      def format_conditions
        (@input[:conditions] || []).collect { |term|
          match = term.match /^([\w\.\s,%]+)\[(\^)?([\w\.]+)\]$/
          if(match)
            value, attr_neg, attr_name = [ $1, $2 ? true : false, $3 ]
            if (column_name?(attr_name))
              value_like = value.include?('%')
              value_set = value.include?(',')

              subject = alias_attr_name(attr_name)
              predicate =
                case [ value_like, value_set, attr_neg ]
                  when [ false, false, false ] then ' = '
                  when [ false, false, true  ] then ' <> '
                  when [ true,  false, false ] then ' ILIKE '
                  when [ true,  false, true  ] then ' NOT ILIKE '
                  when [ false, true,  false ] then ' IN '
                  when [ false, true,  true  ] then ' NOT IN '
                  else fail('unrecognized condition')
                end
              object =
                case [ attr_text?(attr_name), value_set ]
                  when [ false, false ] then value
                  when [ false, true ] then "(#{value})"
                  when [ true, false ] then "'#{value}'"
                end
              "#{ subject }#{ predicate }#{ object }"
            else
              @collection = @collection.send(attr_name, value) # for handling scopes like 'true[is_root_taxon]'
              nil
            end
          else
            term
          end
        }.try(:compact).try(:join, ' AND ')
      end

      def attr_text?(attr_name)
        _attr_text?(attr_name, @model_class)
      end

      def _attr_text?(attr_name, model)
        if attr_name.match(/^([^\.]+)\.(.+)?$/)
          _attr_text?($2, model.reflect_on_association($1.to_sym).klass)
        else
          attr = model.columns_hash[attr_name] || model::Vtattrs.columns_hash[attr_name]
          # not sure if below line works for all cases - had to take into account dates and custom enum fields though
          !attr.number?
        end
      end

      def alias_attr_name(name)
        _alias_attr_name name, @model_class
#        name.match(/^((.+)\.)?([^\.]+)$/)
#        "#{@assoc_path_to_aliases[$2]}.#{$3}"
      end

      def _alias_attr_name attr_name, model, assoc_name = nil
        if attr_name.match(/^([^.]+)\.(.+)$/)
          _alias_attr_name(
            $2,
            model.reflect_on_association($1.to_sym).klass,
            [ assoc_name, $1 ].compact.join('.')
          )
        else
          if model.columns_hash[attr_name]
            "#{@assoc_path_to_aliases[assoc_name]}.#{attr_name}"
          elsif model::Vtattrs.columns_hash[attr_name]
            assoc_name = [ assoc_name, "vsattrs.vtattrs" ].compact.join('.')
            "#{@assoc_path_to_aliases[assoc_name]}.#{attr_name}"
          else fail('attr name not found')
          end
        end
      end

      def column_name?(attr_name)
        _column_name?(attr_name, @model_class)
      end

      def _column_name?(attr_name, model)
        if attr_name.match(/^([^\.]+)\.(.+)?$/)
          _column_name?($2, model.reflect_on_association($1.to_sym).klass)
        else
          (model.columns_hash[attr_name] || model::Vtattrs.columns_hash[attr_name]) ? true : false
        end
      end
    end
  end
end