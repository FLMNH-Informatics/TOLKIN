module SyncRecords
  module AssociationPreload
    def self.included(klass)
      klass.class_eval do
        class << self
          def preload_associations(records, associations, preload_options={})
            records = Array.wrap(records).compact.uniq
            return if records.empty?
            case associations
            when Array then associations.each {|association| preload_associations(records, association, preload_options)}
            when Symbol, String then preload_one_association(records, associations.to_sym, preload_options)
            when Hash then
              associations.each do |parent, options|
                raise "parent must be an association name" unless parent.is_a?(String) || parent.is_a?(Symbol)
                preload_associations(records, parent, options.respond_to?(:reject) ? options.reject{|k,v|k==:include} : {})
                if(options[:include])
                  reflection = reflections[parent]
                  parents = records.sum { |record| Array.wrap(record.send(reflection.name)) }
                  unless parents.empty?
                    parents.first.class.preload_associations(parents, options[:include])
                  end
                end
              end
            end
          end

          private

          def set_association_collection_records(id_to_record_map, reflection_name, associated_records, key)
            associated_records.each do |associated_record|
              mapped_records = id_to_record_map[associated_record[key].to_s]
              debugger unless mapped_records # ADDED
              add_preloaded_records_to_collection(mapped_records, reflection_name, associated_record)
            end
          end

          def set_association_single_records(id_to_record_map, reflection_name, associated_records, key)
            seen_keys = {}
            debugger if associated_records.nil? # ADDED
            associated_records.each do |associated_record|
              #this is a has_one or belongs_to: there should only be one record.
              #Unfortunately we can't (in portable way) ask the database for
              #'all records where foo_id in (x,y,z), but please
              # only one row per distinct foo_id' so this where we enforce that
              next if seen_keys[associated_record[key].to_s]
              seen_keys[associated_record[key].to_s] = true
              mapped_records = id_to_record_map[associated_record[key].to_s]
              debugger if mapped_records.nil? # ADDED
              mapped_records.each do |mapped_record|
                association_proxy = mapped_record.send("set_#{reflection_name}_target", associated_record)
                association_proxy.__send__(:set_inverse_instance, associated_record, mapped_record)
              end
            end

            id_to_record_map.each do |id, records|
              next if seen_keys.include?(id.to_s)
              records.each {|record| record.send("set_#{reflection_name}_target", nil) }
            end
          end

#          def preload_has_many_association(records, reflection, preload_options={})
#            return if records.first.send(reflection.name).loaded?
#            options = reflection.options.merge(preload_options) # CHANGED
#
#            primary_key_name = reflection.through_reflection_primary_key_name
#            id_to_record_map, ids = construct_id_map(records, primary_key_name || reflection.options[:primary_key])
#            records.each {|record| record.send(reflection.name).loaded}
#
#            if options[:through]
#              through_records = preload_through_records(records, reflection, options[:through])
#              through_reflection = reflections[options[:through]]
#              unless through_records.empty?
#                source = reflection.source_reflection.name
#                through_records.first.class.preload_associations(through_records, source, options)
#                through_records.each do |through_record|
#                  through_record_id = through_record[reflection.through_reflection_primary_key].to_s
#                  add_preloaded_records_to_collection(id_to_record_map[through_record_id], reflection.name, through_record.send(source))
#                end
#              end
#
#            else
#              debugger if reflection.primary_key_name.to_s == 'accepted_name_id'
#              set_association_collection_records(id_to_record_map, reflection.name, find_associated_records(ids, reflection, preload_options),
#                                                 reflection.primary_key_name)
#            end
#          end

          def preload_has_and_belongs_to_many_association(records, reflection, preload_options={})
            table_name = reflection.klass.quoted_table_name
            id_to_record_map, ids = construct_id_map(records)
            records.each {|record| record.send(reflection.name).loaded}
            options = reflection.options.merge(preload_options) # LINE CHANGED

            conditions = "t0.#{reflection.primary_key_name} #{in_or_equals_for_ids(ids)}"
            conditions << append_conditions(reflection, preload_options)

            associated_records = reflection.klass.unscoped.where([conditions, ids]).
                includes(options[:include]).
                limit(options[:limit]). # LINE ADDED
                joins(options[:joins]). # LINE ADDED
                joins("INNER JOIN #{connection.quote_table_name options[:join_table]} t0 ON #{reflection.klass.quoted_table_name}.#{reflection.klass.primary_key} = t0.#{reflection.association_foreign_key}").
                #select("#{options[:select].join(', ') || table_name+'.*'}, t0.#{reflection.primary_key_name} as the_parent_record_id").  #MODIFIED OLD WITHOUT CHECK
                select("#{!options[:select].nil? ? options[:select].join(', ') : table_name+'.*'}, t0.#{reflection.primary_key_name} as the_parent_record_id").  #MODIFIED NEW WITH CHECK FOR NIL
                order(options[:order]).to_a

            set_association_collection_records(id_to_record_map, reflection.name, associated_records, 'the_parent_record_id')
          end

          def preload_belongs_to_association(records, reflection, preload_options={})
            return if records.first.send("loaded_#{reflection.name}?")
            options = reflection.options.merge(preload_options) # LINE CHANGED
            primary_key_name = reflection.primary_key_name

            if options[:polymorphic]
              polymorph_type = options[:foreign_type]
              klasses_and_ids = {}

              # Construct a mapping from klass to a list of ids to load and a mapping of those ids back
              # to their parent_records
              records.each do |record|
                if klass = record.send(polymorph_type)
                  klass_id = record.send(primary_key_name)
                  if klass_id
                    id_map = klasses_and_ids[klass] ||= {}
                    id_list_for_klass_id = (id_map[klass_id.to_s] ||= [])
                    id_list_for_klass_id << record
                  end
                end
              end
              klasses_and_ids = klasses_and_ids.to_a
            else
              id_map = {}
              records.each do |record|
                
                key = record.send(primary_key_name) rescue debugger
                if key
                  mapped_records = (id_map[key.to_s] ||= [])
                  mapped_records << record
                end
              end
              klasses_and_ids = [[reflection.klass.name, id_map]]
            end

            klasses_and_ids.each do |klass_and_id|
              klass_name, id_map = *klass_and_id
              next if id_map.empty?
              klass = klass_name.constantize

              table_name = klass.quoted_table_name
              primary_key = reflection.options[:primary_key] || klass.primary_key
              column_type = klass.columns.detect{|c| c.name == primary_key.to_s}.type # MODIFIED SLIGHTLY

              ids = id_map.keys.map do |id|
                if column_type == :integer
                  id.to_i
                elsif column_type == :float
                  id.to_f
                else
                  id
                end
              end

              conditions = "#{table_name}.#{connection.quote_column_name(primary_key)} #{in_or_equals_for_ids(ids)}"
              conditions << append_conditions(reflection, preload_options)

              associated_records = klass.unscoped.where([conditions, ids]).apply_finder_options(options.slice(:include, :select, :limit, :joins, :order, :conditions)).to_a # LINE CHANGED
              set_association_single_records(id_map, reflection.name, associated_records, primary_key)
            end
          end

          def find_associated_records(ids, reflection, preload_options)
            options = reflection.options
            table_name = reflection.klass.quoted_table_name

            if interface = reflection.options[:as]
              conditions = "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_id"} #{in_or_equals_for_ids(ids)} and #{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_type"} = '#{self.base_class.sti_name}'"
            else
              foreign_key = reflection.primary_key_name
              conditions = "#{reflection.klass.quoted_table_name}.#{foreign_key} #{in_or_equals_for_ids(ids)}"
            end

#            conditions << append_conditions(reflection, preload_options) # LINE COMMENTED OUT

            ##### LINES MODIFIED ############
            find_options = {
              :select => options[:select] || Arel::SqlLiteral.new("#{table_name}.*"),
              :include => options[:include],
              :conditions => [conditions, ids],
              :limit => options[:limit], # LINE CHANGED
              :joins => options[:joins],
              :group => options[:group],
              :order => options[:order]
            }
            ##### END LINES MODIFIED ########

            reflection.klass.scoped.apply_finder_options(find_options).apply_finder_options(preload_options).to_a # MODIFIED
          end
        end
      end
    end
  end
end