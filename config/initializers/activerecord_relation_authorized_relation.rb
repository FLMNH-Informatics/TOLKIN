module ActiveRecord
  class Relation
    include Authorized::Relation

    def to_a
     return @records if loaded?

     #debugger if self.klass == Taxon
     @records = eager_loading? ? find_with_associations : @klass.find_by_sql(arel.to_sql)

     preload = @preload_values
     preload +=  @includes_values unless eager_loading?
     preload.each {|associations| @klass.send(:preload_associations, @records, associations) }

     # @readonly_value is true only if set explicitly. @implicit_readonly is true if there
     # are JOINS and no explicit SELECT.
     readonly = @readonly_value.nil? ? @implicit_readonly : @readonly_value
     @records.each { |record| record.readonly! } if readonly

     @loaded = true
     #debugger if self.klass == Taxon
     @records
    end
  end
end
