module Molecular::ImportFastaSeqsHelper
  include Molecular::Insd::SeqsHelper

  def marker_checkbox_list
    @list = ""
    @all_marker_names = (@project.markers.collect { |mrk| mrk.name }).sort {|a,b| a.downcase <=> b.downcase }
    @all_marker_names.each {|name| @list = @list + "<label for='chk_#{name}'><input type='checkbox' id='chk_#{name}' value='#{name}' name='marker_names[]'>#{name}</label><br />"}
    raw @list
  end

  def taxon_name_field
    @taxon_name_field ||= Molecular::Insd::Seqs::TaxonNameAutoTextField.new({
      context: self,
      model_object: @seq,
      parent: viewport_window
    })
  end
end