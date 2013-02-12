ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def foreign_keys(table_name)#:nodoc:
    data = select_all(<<-EOF)
    select t.constraint_name as name, 
            k.table_name as from_table,
    	k.column_name as from_column,
    	c.table_name as to_table, 
    	c.column_name as to_column,
    	r.update_rule as update_rule,
    	r.delete_rule as delete_rule
    from information_schema.table_constraints t,
         information_schema.constraint_column_usage c,
         information_schema.key_column_usage k,
         information_schema.referential_constraints r
    where t.constraint_name = c.constraint_name and 
          k.constraint_name = c.constraint_name and
          r.constraint_name = c.constraint_name and
          t.constraint_type = 'FOREIGN KEY' and
          t.table_name = '#{table_name}'
    EOF
    
    foreign_keys = data.inject({}) do |list, row|
      if !list[row["name"]]
        list[row["name"]] = {
          :name => row["name"],
          :columns => [row["from_column"]],
          :references => row["to_table"],
          :keys => [row["to_column"]],
          :on_update => row["update_rule"],
          :on_delete => row["delete_rule"]
        }
      else
        list[row["name"]][:columns] << row["from_column"]
        list[row["name"]][:keys] << row["to_column"]
      end
      list
    end.map do |key, ref|
      ref[:columns] = Array(ref[:columns]).uniq.compact.join(", ")
      ref[:keys] = Array(ref[:keys]).uniq.compact.join(", ")
      ref.delete(:on_update) if ref[:on_update] == "NO ACTION"
      ref.delete(:on_delete) if ref[:on_delete] == "NO ACTION"
      ref
    end
  end
end
