class IndexedOnTwoDimensionsArray

  def initialize x_attr_name, y_attr_name, obj = nil
    @x_attr_name = x_attr_name
    @y_attr_name = y_attr_name
    @rows_cols_hash = { }
    @cols_rows_hash = { }
    self << obj
  end

  def << items
#    @rows_cols_hash ||= Hash.new
#    @cols_rows_hash ||= Hash.new
    return nil if items.nil?
    [*items].each do |obj|
      @rows_cols_hash[obj.send("#{@x_attr_name}_id")] = Hash.new unless @rows_cols_hash.has_key?(obj.send("#{@x_attr_name}_id"))
      @rows_cols_hash[obj.send("#{@x_attr_name}_id")][obj.send("#{@y_attr_name}_id")] = obj

      @cols_rows_hash[obj.send("#{@y_attr_name}_id")] = Hash.new unless @cols_rows_hash.has_key?(obj.send("#{@y_attr_name}_id"))
      @cols_rows_hash[obj.send("#{@y_attr_name}_id")][obj.send("#{@x_attr_name}_id")] = obj
    end
  end

  def create klass, attrs
    item = klass.create!(attrs)
    self << item
    item
  end

  def delete obj
    @rows_cols_hash[obj.send("#{@x_attr_name}_id")].try(:delete, obj.send("#{@y_attr_name}_id"))
    @cols_rows_hash[obj.send("#{@y_attr_name}_id")].try(:delete, obj.send("#{@x_attr_name}_id"))
  end

  def fetch(row_id, col_id)
    @rows_cols_hash[row_id].nil? ? nil : @rows_cols_hash[row_id][col_id]
  end

  def fetch_for_x x_id
    @rows_cols_hash[x_id] ? @rows_cols_hash[x_id].values : [ ]
  end

  def fetch_for_y y_id
    @cols_rows_hash[y_id] ? @cols_rows_hash[y_id].values : [ ]
  end

  def to_a
    @rows_cols_hash.values.collect{|hash| hash.values}.flatten
  end

  def each &block
    self.to_a.each(&block)
  end

  def replace(remove_coding, add_coding)
    delete remove_coding if remove_coding
    self << add_coding
  end

#  def fetch_for_x_attr(row)
#    @rows_cols_hash[row.id] || {}
#  end
#
#  def fetch_for_y_attr(col)
#    @cols_rows_hash[col.id] || {}
#  end
end