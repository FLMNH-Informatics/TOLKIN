module ActiveRecord
  module Reflection
    class AssociationReflection
      def active_record_foreign_key
        @active_record_foreign_key ||= options[:foreign_key] || active_record.to_s.foreign_key
      end

      def association_primary_key
        @association_primary_key ||= options[:association_primary_key] || klass.primary_key
      end
    end
  end
end
