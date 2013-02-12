module RailsExtensions
  module Acts #:nodoc:
    module HabtmList #:nodoc:
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_habtm_list(options = {})
          configuration = { :column => 'position', :scope => '1 = 1' }
          configuration.update(options) if options.is_a?(Hash)

          configuration[:scope_foreign_key] = "#{ActiveSupport::Inflector.singularize(configuration[:scope])}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

          if configuration[:scope_foreign_key].is_a?(Symbol)
            scope_condition_method = %(
              def scope_condition
                "#{configuration[:scope_foreign_key]} = \#{#{configuration[:scope_foreign_key]}}"
              end
            )
          else
            scope_condition_method = "def scope_condition() \"#{configuration[:scope_foreign_key]}\" end"
          end

          scope_class = ActiveSupport::Inflector.classify(configuration[:scope])
          scope_table_name = ActiveSupport::Inflector.constantize(scope_class).table_name
          join_table_name = join_table_name(scope_table_name, table_name)

          scope_after_add_callback_symbol = "after_add_for_#{table_name}".to_sym
          scope_before_remove_callback_symbol = "before_remove_for_#{table_name}".to_sym

          class_eval <<-EOV
            include RailsExtensions::Acts::HabtmList::InstanceMethods

            def acts_as_list_class
              ::#{self.name}
            end

            def acts_as_habtm_list_scope_colection
              #{scope_class}.find(send(:#{configuration[:scope_foreign_key]})).#{self.name.demodulize.tableize}
            end

            def acts_as_habtm_list_scope_class
              #{scope_class}
            end

            def acts_as_habtm_list_scope_table_name
              '#{scope_table_name}'
            end

            def acts_as_habtm_list_join_table_name
              '#{join_table_name}'
            end

            def position_column
              '#{configuration[:column]}'
            end

            def self_condition
              "#{ActiveSupport::Inflector.foreign_key(self.name)} = \#{id}"
            end

            #{scope_condition_method}
          EOV

          # ChrisG - small fix - added :add_to_list_bottom inside of send to get around 'private method called' error
          ActiveSupport::Inflector.constantize(scope_class).class_eval <<-EOV
            class_inheritable_reader(scope_after_add_callback_symbol)
            write_inheritable_array(
              scope_after_add_callback_symbol,
              (read_inheritable_attribute(scope_after_add_callback_symbol) || []) <<
                Proc.new do |p,c|
                  c.send(:write_attribute, :#{configuration[:scope_foreign_key]}, p.id)
                  c.send(:write_attribute, :#{configuration[:column]}, nil)
                  c.send(:add_to_list_bottom)
                end
            )

            class_inheritable_reader(scope_before_remove_callback_symbol)
            write_inheritable_array(
              scope_before_remove_callback_symbol,
              (read_inheritable_attribute(scope_before_remove_callback_symbol) || []) <<
                Proc.new do |p,c|
                  child = p.#{ActiveSupport::Inflector.tableize(self.name)}.find(c.id) rescue ActiveRecord::RecordNotFound
                  child.remove_from_list if child.kind_of?(ActiveRecord::Base)
                end
            )
          EOV
        end

        private
          def join_table_name(first_table_name, second_table_name)
            if first_table_name < second_table_name
              join_table = "#{first_table_name}_#{second_table_name}"
            else
              join_table = "#{second_table_name}_#{first_table_name}"
            end
            table_name_prefix + join_table + table_name_suffix
          end
      end

      # All the methods available to a record that has had <tt>acts_as_list</tt> specified. Each method works
      # by assuming the object to be the item in the list, so <tt>chapter.move_lower</tt> would move that chapter
      # lower in the list of all chapters. Likewise, <tt>chapter.first?</tt> would return true if that chapter is
      # the first in the list of all chapters.
      module InstanceMethods
        def insert_at(position = 1)
          insert_at_position(position)
        end

        def move_to_position(position)
          return unless in_list? || position.to_i == self.send(position_column).to_i
          remove_from_list
          insert_at_position(position)
        end

        def move_lower
          return unless lower_item
          acts_as_list_class.transaction do
            lower_item.decrement_position
            increment_position
          end
        end

        def move_higher
          return unless higher_item
          acts_as_list_class.transaction do
            higher_item.increment_position
            decrement_position
          end
        end

        def move_to_bottom
          return unless in_list?
          acts_as_list_class.transaction do
            decrement_positions_on_lower_items
            assume_bottom_position
          end
        end

        def move_to_top
          return unless in_list?
          acts_as_list_class.transaction do
            increment_positions_on_higher_items
            assume_top_position
          end
        end

        def remove_from_list
          decrement_positions_on_lower_items if in_list?
          send(position_column+'=', nil)
        end

        def increment_position
          return unless in_list?
          new_position = send(position_column).to_i + 1
          connection.update(
            "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{new_position} " +
            "WHERE #{scope_condition} AND #{self_condition}"
          )
          send(position_column+'=', new_position)
        end

        def decrement_position
          return unless in_list?
          new_position = send(position_column).to_i - 1
          connection.update(
            "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{new_position} " +
            "WHERE #{scope_condition} AND #{self_condition}"
          )
          send(position_column+'=', new_position)
        end

        def first?
          return false unless in_list?
          self.send(position_column).to_i == 1
        end

        def last?
          return false unless in_list?
          self.send(position_column) == bottom_position_in_list.to_i
        end

        def higher_item
          return nil unless in_list?
          acts_as_habtm_list_scope_colection.find(:first, :conditions =>
            "#{position_column} = #{(send(position_column).to_i - 1).to_s}"
          )
        end

        def lower_item
          return nil unless in_list?
          acts_as_habtm_list_scope_colection.find(:first, :conditions =>
            "#{position_column} = #{(send(position_column).to_i + 1).to_s}"
          )
        end

        def in_list?
          !send(position_column).nil?
        end

        def add_to_list_bottom
          # ChrisG - small fix for duplicate after_add callbacks
          new_position = bottom_position_in_list(self).to_i + 1
          connection.update(
            "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{new_position} " +
            "WHERE #{scope_condition} AND #{self_condition}"
          )
          send(position_column+'=', new_position)
        end

        private
          def add_to_list_top
            increment_positions_on_all_items
          end

          # Overwrite this method to define the scope of the list changes
          def scope_condition() "1" end

          def bottom_position_in_list(except = nil)
            item = bottom_item(except)
            item ? item.send(position_column) : 0
          end

          def bottom_item(except = nil)
            conditions = except.nil? ? '1 = 1' : "id != #{except.id}"
            acts_as_habtm_list_scope_colection.find(:first, :conditions => conditions, :order => "#{position_column} DESC")
          end

          def assume_bottom_position
            new_position = bottom_position_in_list(self).to_i + 1
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{new_position} " +
              "WHERE #{scope_condition} AND #{self_condition}"
            )
            send(position_column+'=', new_position)
          end

          def assume_top_position
            new_position = 1
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{new_position} " +
              "WHERE #{scope_condition} AND #{self_condition}"
            )
            send(position_column+'=', new_position)
          end

          # This has the effect of moving all the higher items up one.
          def decrement_positions_on_higher_items(position)
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = (#{position_column} - 1) " +
              "WHERE #{scope_condition} AND #{position_column} <= #{position}"
            )
            send(position_column+'=', send(position_column) - 1) if in_list? && send(position_column) <= position
          end

          # This has the effect of moving all the lower items up one.
          def decrement_positions_on_lower_items
            return unless in_list?
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = (#{position_column} - 1) " +
              "WHERE #{scope_condition} AND #{position_column} > #{send(position_column).to_i}"
            )
          end

          # This has the effect of moving all the higher items down one.
          def increment_positions_on_higher_items
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = (#{position_column} + 1) " +
              "WHERE #{scope_condition} AND #{position_column} < #{send(position_column).to_i}"
            )
          end

          # This has the effect of moving all the lower items down one.
          def increment_positions_on_lower_items(position)
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = (#{position_column} + 1) " +
              "WHERE #{scope_condition} AND #{position_column} >= #{position}"
            )
            send(position_column+'=', send(position_column) + 1) if in_list? && send(position_column) >= position
          end

          def increment_positions_on_all_items
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = (#{position_column} + 1) " +
              "WHERE #{scope_condition}"
            )
            send(position_column+'=', send(position_column) + 1) if in_list?
          end

          def insert_at_position(position)
            remove_from_list
            increment_positions_on_lower_items(position)
            connection.update(
              "UPDATE #{acts_as_habtm_list_join_table_name} SET #{position_column} = #{position} " +
              "WHERE #{scope_condition} AND #{self_condition}"
            )
            send(position_column+'=', position)
          end
      end
    end
  end
end
