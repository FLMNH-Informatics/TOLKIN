module ActiveRecord
  module Associations
    class HasAndBelongsToManyAssociation
      def construct_sql
        if @reflection.options[:finder_sql]
          @finder_sql = interpolate_and_sanitize_sql(@reflection.options[:finder_sql])
        else
          @finder_sql = "#{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.active_record_foreign_key} = #{@owner.quoted_attribute @reflection.active_record_primary_key} " # MODIFIED
          @finder_sql << " AND (#{conditions})" if conditions
        end

        @join_sql = "INNER JOIN #{@owner.connection.quote_table_name @reflection.options[:join_table]} ON #{@reflection.quoted_table_name}.#{@reflection.association_primary_key} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key}" # MODIFIED

        construct_counter_sql
      end
    end
  end
end
