ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
  def foreign_keys(table_name)#:nodoc:
    sql = execute("SHOW CREATE TABLE #{quote_table_name(table_name)}").fetch_hash["Create Table"]

    foreign_keys = []
    sql.scan(/CONSTRAINT `(\w+)` FOREIGN KEY \((.*?)\) REFERENCES `(\w+)` \((.*?)\)(?:\s+ON DELETE\s+(.*?))?(?:\s+ON UPDATE\s+(.*?))?[,\)\n]/) do |name, column_list, references, key_list, on_delete, on_update|
      columns = []; column_list.scan(/`(\w+)`/) { |match| columns << match.first }
      keys = []; key_list.scan(/`(\w+)`/) { |match| keys << match.first }

      foreign_keys << {
        :name => name,
        :columns => columns,
        :references => references,
        :keys => keys,
        :on_update => on_update,
        :on_delete => on_delete
      }
    end

    foreign_keys
  end
end
