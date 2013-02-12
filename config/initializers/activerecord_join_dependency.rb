module ActiveRecord
  module Associations
    module ClassMethods


      class JoinDependency
#        class JoinBase
#          def extract_record(row)
#            row # CHANGED - BYPASSING WHOLE OF ALIASING
#          end
#
#          def record_id(row)
#            row[primary_key] # CHANGED - BYPASSING WHOLE OF ALIASING
#          end
#        end
#
#        def instantiate(rows)
#          rows.each_with_index do |row, i|
#            primary_id = join_base.record_id(row)
#            unless @base_records_hash[primary_id]
#              @base_records_in_order << (@base_records_hash[primary_id] = join_base.instantiate(row))
#            end
#            construct(@base_records_hash[primary_id], @associations, join_associations.dup, row)
#          end
#          remove_duplicate_results!(join_base.active_record, @base_records_in_order, @associations)
#          return @base_records_in_order
#        end

        protected

        def build_without_metawhere(associations, parent = nil, join_type = Arel::InnerJoin)
          parent ||= @joins.last
          case associations
            when Symbol, String
              reflection = parent.reflections[associations.to_s.intern] or
              raise ConfigurationError, "Association named '#{ associations }' was not found; perhaps you misspelled it?"
              unless join_association = find_join_association(reflection, parent)
                @reflections << reflection
                join_association = build_join_association(reflection, parent)
                join_association.join_type = join_type
                @joins << join_association
                cache_joined_association(join_association)
              end
              join_association
            when Array
              associations.each do |association|
                build(association, parent, join_type)
              end
            when Hash
              if associations[:include] # ADDED
                build(associations[:include], parent, join_type) # ADDED
              else # ADDED
                associations.keys.
                  reject{|k|[:select,:limit,:include].include?(k)}. # ADDED
                  sort{|a,b|a.to_s<=>b.to_s}.
                  each do |name|
                    join_association = build(name, parent, join_type)
                    build(associations[name], join_association, join_type)
                  end
              end # ADDED
            else
              raise ConfigurationError, associations.inspect
          end
        end
      end
    end
  end
end