ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do
  # Adds a new foreign key to a table.  +columns+ can be a single Symbol, or an
  # array of Symbols, on which the key will be added.
  #
  # The referenced table name and columns are deduced using the usual conventions
  # unless explicitly specified via +:references+ and/or +:keys+ options.
  #
  # The foreign key will be named using the same rules as #add_index, unless you
  # pass +:name+ as an option.
  #
  # Options for +:on_delete+ and +:on_update+ may be specified.  Acceptable
  # values are +:restrict+, +:set_null+, and +:cascade+.
  #
  # Note that some databases will automatically create an index on the constrained
  # columns.
  #
  # ===== Examples
  # ====== Creating a simple foreign key
  #  add_foreign_key :orders, :user_id
  # generates
  #  ALTER TABLE orders ADD CONSTRAINT index_orders_on_user_id FOREIGN KEY (user_id) REFERENCES users (id)
  # ====== Specifying the target table
  #  add_foreign_key :articles, :author_id, :references => :users
  # generates
  #  ALTER TABLE articles ADD CONSTRAINT index_articles_on_author_id FOREIGN KEY (author_id) REFERENCES users (id)
  # ====== Cascading deletes
  #  add_foreign_key :comments, :post_id, :on_delete => :cascade
  # generates
  #  ALTER TABLE comments ADD CONSTRAINT index_comments_on_post_id FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
  def add_foreign_key(table_name, columns, options = {})
    columns = Array(columns)
    name = options[:name] || index_name(table_name, :column => columns)
    column_list = columns.collect { |column| quote_column_name(column) }.join(", ")
    keys = Array(options[:keys] || :id)
    key_list = keys.collect { |key| quote_column_name(key) }.join(", ")
    references = if options[:references]
      options[:references]
    else
      columns.first.to_s.gsub(/_id$/, '').tableize
    end

    sql = "ALTER TABLE #{quote_table_name(table_name)} ADD CONSTRAINT #{quote_column_name(name)} FOREIGN KEY (#{column_list}) REFERENCES #{quote_table_name(references)} (#{key_list})"
    sql << " ON DELETE #{options[:on_delete].to_s.gsub(/_/,' ')}" if options[:on_delete]
    sql << " ON UPDATE #{options[:on_update].to_s.gsub(/_/,' ')}" if options[:on_update]
    execute sql
  end

  # Remove the given foreign key from the table.  If +:name+ is specified, it will be used
  # directly as the name of the key to delete.  Otherwise, the same conventions used
  # when by #add_foreign_key may be provided.
  #
  # Any underlying indexes will not be automatically dropped.
  #
  # ===== Examples
  # ====== Removing a foreign key by name
  #  remove_foreign_key :orders, :name => "index_orders_on_user_id"
  # ====== Removing a foreign key by column
  #  remove_foreign_key :orders, :user_id
  def remove_foreign_key(table_name, *args)
    options = args.extract_options!
    name = if options[:name]
      options[:name]
    else
      columns = args.first
      index_name(table_name, :column => Array(columns))
    end

    execute "ALTER TABLE #{quote_table_name(table_name)} DROP FOREIGN KEY #{quote_column_name(name)}"
  end
end
