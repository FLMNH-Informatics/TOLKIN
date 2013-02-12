module Restful
  module Mixins
    module FormatInclude
      def format_include
        @alias_count = {}
        @select_set ||= Set.new
        _index_aliases(@input[:include], @model_class, Set.new.add(@model_class.table_name))
        @out[:joins] = @input[:include]
        #@out[:include] = _format_include(@input[:include])[1]
      end

      def _select_add_keys reflection, model, old_path, new_path
        case reflection.macro
          when :belongs_to
            primary_key = reflection.options[:primary_key] || reflection.klass.primary_key
            foreign_key = reflection.options[:foreign_key] || "#{reflection.name}_id"
            @select_set.add("#{@assoc_path_to_aliases[new_path]}.#{primary_key}")
            @select_set.add("#{@assoc_path_to_aliases[old_path]}.#{foreign_key}")
          when :has_one, :has_many
            primary_key = reflection.options[:primary_key] || model.primary_key
            foreign_key =
              ( reflection.options[:foreign_key] ) ||
              ( reflection.options[:as] && "#{reflection.options[:as]}_id" ) ||
              ( "#{model.to_s.demodulize.underscore}_id" )
            @select_set.add("#{@assoc_path_to_aliases[new_path]}.#{foreign_key}")
            @select_set.add("#{@assoc_path_to_aliases[old_path]}.#{primary_key}")
          when :has_and_belongs_to_many
            primary_key       = model.primary_key
            assoc_primary_key = reflection.klass.primary_key
#            foreign_key       = reflection.options[:foreign_key]       || "#{model.to_s.demodulize.underscore}_id"
#            assoc_foreign_key = reflection.options[:assoc_foreign_key] || "#{reflection.klass.to_s.demodulize.underscore}_id"
#            join_table = reflection.options[:join_table] || fail("no default join table handled")
            @select_set.add("#{@assoc_path_to_aliases[old_path]}.#{primary_key}")
            @select_set.add("#{@assoc_path_to_aliases[new_path]}.#{assoc_primary_key}")
#            select_set.add("#{join_table}.#{foreign_key}")
#            select_set.add("#{join_table}.#{assoc_foreign_key}")
          else debugger #fail 'unrecognized macro'
        end
      end

      def _index_aliases input, model, seen_aliases, assoc_path = nil
        if(input.respond_to?(:each)) # MUST BE HASH STRUCTURED
          (input.respond_to?(:keys) ? input.keys.sort : input ).each do |v1| # MUST BE ALPHABETICAL SO THAT ALIAS ORDERING MATCHES WITH RAILS INCLUDE ORDERING
            _index_aliases(v1, model, seen_aliases, assoc_path)
            v2 = input.respond_to?(:keys) ? input[v1] : nil
            if(v2)
              v1_assoc_name = v1.respond_to?(:name) ? v1.name : v1.to_sym
              _index_aliases(
                v2,
                model.reflect_on_association(v1_assoc_name).klass,
                seen_aliases,
                [ assoc_path, v1_assoc_name ].compact.join('.')
              )
            end
          end
        else
          assoc_name = input.respond_to?(:name) ? input.name : input
          assoc = model.reflect_on_association(assoc_name)
          new_path = [assoc_path, assoc_name].compact.join('.')
          table_name = assoc.klass.table_name

          unless(seen_aliases.include?(table_name))
            alias_name = table_name
            seen_aliases.add(alias_name)
          else
            alias_name = "#{assoc_name.to_s.pluralize}_#{model.table_name}"
          end
          @assoc_path_to_aliases[new_path] =
            [ alias_name,
              @alias_count[alias_name.to_sym].nil? ? nil : @alias_count[alias_name.to_sym] + 1
            ].compact.join('_')
          @alias_count[alias_name.to_sym] = (@alias_count[alias_name.to_sym] || 0) + 1
          _select_add_keys assoc, model, assoc_path, new_path
        end
      end
    end
  end
end