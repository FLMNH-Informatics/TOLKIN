module ActiveRecord
  class Relation
    def calculate(operation, column_name, options = {})
      if options.except(:distinct).present?
        apply_finder_options(options.except(:distinct)).calculate(operation, column_name, :distinct => options[:distinct])
      else
        # ChrisG - REMOVED CONDITION THAT WAS CAUSING LIMIT CONDITION TO BE APPLIED BEFORE COUNT
        #if eager_loading? || includes_values.present? # REMOVED
        #  construct_relation_for_association_calculations.calculate(operation, column_name, options) # REMOVED
        #else # REMOVED
          perform_calculation(operation, column_name, options)
        #end # REMOVED
      end
    rescue ThrowResult
      0
    end

    private
    
    def execute_simple_calculation(operation, column_name, distinct) #:nodoc:
      column = aggregate_column(column_name)

      # Postgresql doesn't like ORDER BY when there are no GROUP BY
      relation = except(:order, :offset, :limit) # CHANGED 2/11/11 - OTHERWISE COUNT QUERIES ARE SCREWED
      select_value = operation_over_aggregate_column(column, operation, distinct)

      relation.select_values = [select_value]

      type_cast_calculated_value(@klass.connection.select_value(relation.to_sql), column_for(column_name), operation)
    end
  end
end