module ActiveRecord
  module Associations
    class HasManyThroughAssociation
      def construct_quoted_owner_attributes(reflection)
        if as = reflection.options[:as]
          { "#{as}_id" => owner_quoted_id,
            "#{as}_type" => reflection.klass.quote_value(
              @owner.class.base_class.name.to_s,
              reflection.klass.columns_hash["#{as}_type"]) }
        elsif reflection.macro == :belongs_to
          { (reflection.options[:primary_key] || reflection.klass.primary_key) => @owner.class.quote_value(@owner[reflection.primary_key_name]) } # MODIFIED
        else
          { reflection.primary_key_name => @owner.class.quote_value(@owner[reflection.options[:primary_key] || reflection.active_record.primary_key]) } # MODIFIED - ChrisG - Apr 19th, 2011
        end
      end

      def construct_joins(custom_joins = nil)
        polymorphic_join = nil
        if @reflection.source_reflection.macro == :belongs_to
          reflection_primary_key = @reflection.through_reflection.options[:primary_key] || @reflection.klass.primary_key # MODIFIED
          source_primary_key     = @reflection.source_reflection.primary_key_name
          if @reflection.options[:source_type]
            polymorphic_join = "AND %s.%s = %s" % [
              @reflection.through_reflection.quoted_table_name, "#{@reflection.source_reflection.options[:foreign_type]}",
              @owner.class.quote_value(@reflection.options[:source_type])
            ]
          end
        else
          reflection_primary_key = @reflection.source_reflection.primary_key_name
          source_primary_key     = @reflection.through_reflection.options[:primary_key] || @reflection.through_reflection.klass.primary_key # MODIFIED
          if @reflection.source_reflection.options[:as]
            polymorphic_join = "AND %s.%s = %s" % [
              @reflection.quoted_table_name, "#{@reflection.source_reflection.options[:as]}_type",
              @owner.class.quote_value(@reflection.through_reflection.klass.name)
            ]
          end
        end

        "INNER JOIN %s ON %s.%s = %s.%s %s #{@reflection.options[:joins]} #{custom_joins}" % [
          @reflection.through_reflection.quoted_table_name,
          @reflection.quoted_table_name, reflection_primary_key,
          @reflection.through_reflection.quoted_table_name, source_primary_key,
          polymorphic_join
        ]
      end
    end
  end
end
