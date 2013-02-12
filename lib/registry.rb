class Registry

  attr_reader :owner

  def initialize options
    @owner = options[:owner] || fail("owner required")
    @id_to_obj = {}
    @name_to_obj = {}
    @id_to_name = {}
    self << options[:initial_entries] if options[:initial_entries]
  end

  def <<(to_add)
    to_add.each do |name,item|
      self[name] = item
    end
  end

  def [](id)
    @id_to_obj[id] || @name_to_obj[id]
  end

  def []=(name, item)
    @id_to_obj[item.id] = item if item.respond_to?(:id)
    @name_to_obj[name] = item
    @id_to_name[item.id] = name if item.respond_to?(:id)
  end

  def each &block
    @name_to_obj.each &block
  end

  def delete *to_delete
    to_delete.each do |item|
      if(@id_to_obj[item.id] == item)
        name = @id_to_name[item.id]
        @id_to_name.delete(id)
        @id_to_obj.delete(id)
        @name_to_obj.delete(name)
      end
    end
  end
end


