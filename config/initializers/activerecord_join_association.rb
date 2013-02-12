module ActiveRecord
  module Associations
    module ClassMethods
      class JoinDependency
        class JoinAssocation
          def association_join
            return @join if @join

            aliased_table = Arel::Table.new(table_name, :as      => @aliased_table_name,
                                            :engine  => arel_engine,
                                            :columns => klass.columns)

            parent_table = Arel::Table.new(parent.table_name, :as => parent.aliased_table_name,
                                           :engine  => arel_engine,
                                           :columns => parent.active_record.columns)

            @join = case reflection.macro
                    when :has_and_belongs_to_many
                      join_table = Arel::Table.new(options[:join_table], :as => aliased_join_table_name, :engine => arel_engine)
                      pk = options[:primary_key] || reflection.active_record.primary_key # MODIFIED
                      fk = options[:foreign_key] || reflection.active_record.foreign_key # MODIFIED
                      klass_pk = options[:association_primary_key] || klass.primary_key # MODIFIED
                      klass_fk = options[:association_foreign_key] || klass.foreign_key # MODIFIED

                      [
                        join_table[fk].eq(parent_table[pk]), # MODIFIED
                        aliased_table[klass_pk].eq(join_table[klass_fk]) # MODIFIED
                      ]
                    when :has_many, :has_one
                      if reflection.options[:through]
                        join_table = Arel::Table.new(through_reflection.klass.table_name, :as => aliased_join_table_name, :engine => arel_engine)
                        jt_as_extra = jt_source_extra = jt_sti_extra = nil
                        first_key = second_key = as_extra = nil

                        if through_reflection.macro == :belongs_to
                          jt_primary_key = through_reflection.primary_key_name
                          jt_foreign_key = through_reflection.association_primary_key
                        else
                          jt_primary_key = through_reflection.active_record_primary_key
                          jt_foreign_key = through_reflection.primary_key_name

                          if through_reflection.options[:as] # has_many :through against a polymorphic join
                            jt_as_extra = join_table[through_reflection.options[:as].to_s + '_type'].eq(parent.active_record.base_class.name)
                          end
                        end

                        case source_reflection.macro
                        when :has_many
                          if source_reflection.options[:as]
                            first_key   = "#{source_reflection.options[:as]}_id"
                            second_key  = options[:foreign_key] || primary_key
                            as_extra    = aliased_table["#{source_reflection.options[:as]}_type"].eq(source_reflection.active_record.base_class.name)
                          else
                            first_key   = through_reflection.klass.base_class.to_s.foreign_key
                            second_key  = options[:foreign_key] || primary_key
                          end

                          unless through_reflection.klass.descends_from_active_record?
                            jt_sti_extra = join_table[through_reflection.active_record.inheritance_column].eq(through_reflection.klass.sti_name)
                          end
                        when :belongs_to
                          first_key = primary_key
                          if reflection.options[:source_type]
                            second_key = source_reflection.association_foreign_key
                            jt_source_extra = join_table[reflection.source_reflection.options[:foreign_type]].eq(reflection.options[:source_type])
                          else
                            second_key = source_reflection.primary_key_name
                          end
                        end

                        [
                          [parent_table[jt_primary_key].eq(join_table[jt_foreign_key]), jt_as_extra, jt_source_extra, jt_sti_extra].reject{|x| x.blank? },
                          aliased_table[first_key].eq(join_table[second_key])
                        ]
                      elsif reflection.options[:as]
                        id_rel = aliased_table["#{reflection.options[:as]}_id"].eq(parent_table[parent.primary_key])
                        type_rel = aliased_table["#{reflection.options[:as]}_type"].eq(parent.active_record.base_class.name)
                        [id_rel, type_rel]
                      else
                        foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
                        [aliased_table[foreign_key].eq(parent_table[reflection.options[:primary_key] || parent.primary_key])]
                      end
                    when :belongs_to
                      [aliased_table[options[:primary_key] || reflection.klass.primary_key].eq(parent_table[options[:foreign_key] || reflection.primary_key_name])]
                    end

            unless klass.descends_from_active_record?
              sti_column = aliased_table[klass.inheritance_column]
              sti_condition = sti_column.eq(klass.sti_name)
              klass.descendants.each {|subclass| sti_condition = sti_condition.or(sti_column.eq(subclass.sti_name)) }

              @join << sti_condition
            end

            [through_reflection, reflection].each do |ref|
              if ref && ref.options[:conditions]
                @join << process_conditions(ref.options[:conditions], aliased_table_name)
              end
            end

            @join
          end
        end
      end
    end
  end
end
