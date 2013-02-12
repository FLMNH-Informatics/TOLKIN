module Restful
  class Preparer
    def initialize options
      @resource = options[:resource] || nil
    end

    def prepare struct, options
      mod =
        case options[:for].to_s
          when 'finder'
            struct = struct.select{|k,v|[ :select, :joins, :include, :order, :offset, :limit, :conditions ].include?(k.to_sym) }
            Restful::Preparer::ForFinder
          when 'formatter'
            Restful::Preparer::ForFormatter
          else fail "unknown for condition"
        end
      new_struct = dup_struct(struct)
      mod.prepare_node(new_struct, @resource)

    end

    private

    def dup_struct struct
      case struct
      when Hash
        out = {}
        struct.each do |k,v|
          out[k.to_sym] = dup_struct(v)
        end
        out
      when Array
        out = []
        struct.each do |v|
          out << dup_struct(v)
        end
        out
      else
        struct
      end
    end

    module ForFormatter
      class << self
        def prepare_node node, resource
          # do no formatting for now
          node
        end
      end
    end

    module ForFinder
      class << self
        def prepare_node node, resource
          merge_select_scopes node, resource
          prepare_joins node, resource
#          index_joins node[:joins], resource, joins_index = {}
          prepare_select node, resource #, joins_index # must follow index_joins
          prepare_conds node
#          prepare_order node, joins_index # must follow index_joins
          prepare_includes node[:include], resource
          node
        end

        def prepare_conds node
#          if(node[:conditions])
#            out = nil
#            node[:conditions].each do |cond|
#              next if cond == 'true'
#              if cond == 'false'
#                out = "false"
#                break
#              end
#              debugger
#              cond.match(/([\w,%\.]+)\[([\w\.]+)\]/)
#              k, v = $2, $1
#              case
#              when v.include?('%')
#                to_add = ( k.to_sym =~ v )
#                out = out ? (out & to_add) : to_add
#              when v.include?(',')
#                to_add = ( k.to_sym + v.split(',') )
#                out = out ? (out & to_add) : to_add
#              else
#                to_add = { k.to_sym => v }
#                out = out ? (out & to_add) : to_add
#              end
#            end
            node[:conditions] #= out
#          end
        end

        def prepare_joins node, resource
          node[:joins] = [*node[:joins]].collect{|item| item.to_s.match(/^\w+$/) ? item.to_sym : item} if (node[:joins])
        end

        def merge_select_scopes node, resource
          if(node[:select])
            node[:select], for_select_scoping =
              [*node[:select]].
                select{|s|s.kind_of?(String) || s.kind_of?(Symbol)}. # reject hashes and the like (hash used for { except: })
                partition { |select| resource.has_column?(select) }
            for_select_scoping.each { |select| node.deep_merge!(resource.select_scope(select.to_sym)) }
          end
        end

#        def index_joins joins, resource, joins_index, assoc_path = nil, seen_aliases = Set.new
#          if joins
#            case joins
#            when Hash
#              joins.each do |k,v|
#                index_joins k, resource, joins_index, assoc_path, seen_aliases
#                index_joins v, resource.reflect_on_association(k).klass, joins_index, [assoc_path, k].compact.join('.'), seen_aliases
#              end
#            when Array
#              joins.each do |join|
#                index_joins join, resource, joins_index, assoc_path, seen_aliases
#              end
#            when Symbol
#              table_name = resource.reflect_on_association(k).klass.table_name
#              assoc_path = [assoc_path, joins].compact.join('.')
#              if(seen_aliases.include?(table_name))
#                fail "haven't handled this yet"
#              else
#                joins_index[assoc_path] = table_name
#                seen_aliases.add(table_name)
#              end
#            else fail "unknown join structure"
#            end
#          end
#        end

#        def prepare_order node, joins_index
#          if node[:order]
#            node[:order] =
#              node[:order].collect do |attr|
#                attr.sub(/^([\w\.]+)\.(\w+)/) { |match| "#{joins_index[match[1]]}.#{match[2]}" }
#              end
#          end
#        end

        def prepare_includes includes, resource
          if includes
            case includes
            when Hash
              includes.each do |k,v|
                debugger if resource.reflect_on_association(k).nil?
                prepare_node v, resource.reflect_on_association(k).klass
              end
            when Array # do nothing
            when Symbol # do nothing
            else fail "unknown include structure"
            end
          end
        end

        def prepare_select node, resource
#          debugger
          node[:select] &&
            node[:select] =
              node[:select].
                select{|s| s.kind_of?(String) || s.kind_of?(Symbol)}.
                collect {|s| "#{resource.table_name}.#{s}" }
        end
      end
    end
  end
end
