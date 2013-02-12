#class Morphology::CodingsContainer
#  include
#
#  X_ITEM_CLASS = "Morphology::Character"
#  X_ITEM_NAME = "character"
#  Y_ITEM_CLASS = "Otu"
#  Y_ITEM_NAME = "otu"
#  CELL_CLASS = "Morphology::StateCoding"
#  CELL_NAME = "coding"
#
#  def initialize
#    @row_attr_name, @col_attr_name = :otu, :character
#    @rows_cols_hash = Hash.new
#    @cols_rows_hash = Hash.new
#    #@rows_cols_hash.private :[]=#(key, val)
#    #  raise "Module.#{self.to_s}Setting not allowed, please use the library method."
#    #end
#
#    #@cols_rows_hash.private :[]=#(key, val)
#    #  raise "Module.#{self.to_s}Setting not allowed, please use the library method."
#    #end
#  end
#  #default usage of container is by row index if want to access by
#  #def []=(key, value)
#  #  @rows_cols_hash[key] = value
#  #end
#
#  #def [](key)
#  #  @rows_cols_hash[key]
#  #end
#
#  #def transpose
#  #  @cols_rows_hash
#  #end
#  def add_codings(codings)
#    add_obj(codings)
#  end
#
#  def self.for_codings(codings)
#    coding_cont = Morphology::CodingsContainer.new
#    coding_cont.add_codings(codings)
#    coding_cont
#  end
#
#  def remove_codings(codings)
#    remove_obj(codings)
#  end
#
#  def add_coding(coding)
#    add_obj(coding)
#  end
#
#  def remove_coding(coding)
#    remove_obj(coding)
#  end
#
#  def replace(remove_coding, add_coding)
#    remove_obj(remove_coding) if remove_coding
#    add_obj(add_coding)
#  end
#
#  def coding_by_otu_id_chr_id(otu_id, chr_id)
#    fetch(otu_id, chr_id)
#  end
#
#  def coding_by_chr_id_otu_id(chr_id, otu_id)
#    fetch(otu_id, chr_id)
#  end
#
#  def coding(index1_obj, index2_obj)
#    raise "Type Mismatch for indexes" unless (index1_obj.kind_of?(Morphology::Character) && index2_obj.kind_of?(Otu)) || (index1_obj.kind_of?(Otu) && index2_obj.kind_of?(Morphology::Character))
#    if index1_obj.kind_of?(Otu)
#      return fetch(index1_obj.id, index2_obj.id)
#    else
#      return fetch(index2_obj.id, index1_obj.id)
#    end
#  end
#
#  def codings_for_character(chr)
#    raise "chr is not a Morphology::Character" unless chr.kind_of?(Morphology::Character)
#    objs_for_col(chr)
#  end
#
#  def codings_for_otu(otu)
#    raise "chr is not a Otu" unless otu.kind_of?(Otu)
#    objs_for_row(otu)
#  end
#
#  private
#  def [](key)
#    @rows_cols_hash[key]
#  end
#end