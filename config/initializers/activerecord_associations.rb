module ActiveRecord
  module Associations
    module ClassMethods
      @@valid_keys_for_has_and_belongs_to_many_association = [
        :class_name, :table_name, :join_table, :primary_key, :foreign_key, :association_primary_key, :association_foreign_key, # MODIFIED
        :select, :conditions, :include, :order, :group, :having, :limit, :offset,
        :uniq,
        :finder_sql, :counter_sql, :delete_sql, :insert_sql,
        :before_add, :after_add, :before_remove, :after_remove,
        :extend, :readonly,
        :validate
      ]
    end
  end
end
