ActiveRecord::SchemaDumper.class_eval do
  private

  def tables(stream)
    table_names = @connection.tables.sort.reject do |tbl|
      ['schema_migrations', 'schema_info', ignore_tables].flatten.any? do |ignored|
        case ignored
        when String; tbl == ignored
        when Regexp; tbl =~ ignored
        else
          raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
        end
      end 
    end

    table_names.each { |tbl| table(tbl, stream) }
    table_names.each { |tbl| foreign_keys(tbl, stream) } if @connection.respond_to?(:foreign_keys)
  end

  def foreign_keys(table, stream)
    foreign_keys = @connection.foreign_keys(table).sort { |a, b| a[:columns] <=> b[:columns] }
    foreign_keys.each do |foreign_key|
      stream.print "  add_foreign_key #{table.inspect}, #{foreign_key[:columns].inspect}"
      stream.print ", :references => #{foreign_key[:references].inspect}" if foreign_key[:references] && foreign_key[:references] != foreign_key[:columns].first.gsub(/_id$/, '').tableize
      stream.print ", :keys => #{foreign_key[:keys].inspect}" if foreign_key[:keys] && foreign_key[:keys] != ["id"]
      stream.print ", :name => #{foreign_key[:name].inspect}" if foreign_key[:name]
      stream.print ", :on_delete => #{foreign_key[:on_delete].downcase.gsub(/ /, '_').to_sym.inspect}" if foreign_key[:on_delete]
      stream.print ", :on_update => #{foreign_key[:on_update].downcase.gsub(/ /, '_').to_sym.inspect}" if foreign_key[:on_update]
      stream.puts
    end
    stream.puts unless foreign_keys.empty?
  end
end
