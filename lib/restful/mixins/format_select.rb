module Restful
  module Mixins
    module FormatSelect
      def format_select
        # DEBUG ME @assoc_path_to_aliases PROBABLY NOT BEING FILLED IN I AM OUTPUTTING .*, .name, .description, etc...
        @input[:select].each do |select|
          _alias_select(select, @model_class, Set.new)
        end
        @out[:select] = @select_set.to_a.join(',')
      end

      def _alias_select attr, model, seen_assoc_paths, assoc_path = nil

        if(attr.match(/^(\w+)\.([\w\.\*]+)$/))
          assoc_reflect = model.reflect_on_association($1.to_sym)
          if assoc_reflect
            new_assoc_path = [ assoc_path, $1 ].compact.join('.')
            _alias_select($2, assoc_reflect.klass, seen_assoc_paths, new_assoc_path)
          elsif model.const_defined?("Vtattrs") && model::Vtattrs.reflect_on_association($1.to_sym)
            _alias_select("vsattrs.vtattrs.#{attr}", model, seen_assoc_paths, assoc_path)
          end
        else
          if(model && model.attr?(attr))
            if (comp = model.composite(attr))
              comp.attrs.collect do |sub_attr|
                _alias_select(sub_attr, model, seen_assoc_paths, assoc_path)
              end
            else
              alias_name = @assoc_path_to_aliases[assoc_path]
              unless (seen_assoc_paths.include?(assoc_path))
                seen_assoc_paths.add(assoc_path)
              end
              fail "alias for #{assoc_path} not found" unless alias_name
              @select_set.add("#{alias_name}.#{attr}")
            end
          elsif (model && model::Vtattrs.attr?(attr))
            _alias_select("vsattrs.vtattrs.#{attr}", model, seen_assoc_paths, assoc_path)
          end
        end
      end
    end
  end
end