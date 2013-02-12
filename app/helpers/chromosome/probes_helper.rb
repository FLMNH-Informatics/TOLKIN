module Chromosome::ProbesHelper

  def probes_catalog
    Chromosome::Probes::Catalog.new({
        collection: @probes,
        parent: content_frame
      }).render_to_string
  end

  #def dyes_catalog
  #  Chromosome::Probes::Dyescatalog.new({
  #      collection: @dye_compositions,
  #      parent: content_frame
  #    }).render_to_string
  #end

  #def zfiles_catalog
  # Chromosome::Probes::Zfilescatalog.new({
  #      collection: @z_files,
  #      parent: content_frame
  #    }).render_to_string
  #end
  
  def probe_z_files_list
    Chromosome::Probes::ProbeZFilesList.new({
        context: self,
        z_files: @probe_z_files1,
        parent: content_frame })
  end

  def probe_dye_compositions_list
    Chromosome::Probes::ProbeDyeCompositionsList.new({
        context: self,
        dye_compositions: @probe_dye_compositions1,
        parent: content_frame })
  end
  
  def text_field_or_text obj, meth 
    if interact_mode == 'edit'
      raw %Q{ <input name="probe[#{meth}]" type="text" size="15" value="#{obj.send(meth)}" /> }
    else
      raw %Q{ <span>#{obj.send(meth)}</span> }
    end 
  end

  def select_field_or_text collection, text, id 
    if interact_mode == 'edit'
      raw %Q{ <select name="probe[#{meth}]" type="text" size="15" value="" >#{options_from_collection_for_select(collection, id, text)} </select> }
    else
      raw %Q{ <span>#{obj.send(meth)}</span> }
    end    
  end

  def probe_type_field(val)
    if interact_mode == 'edit'
      out = '<select name="probe[probe_type]">'
      ['BAC', 'PCR', 'Oligo'].each{|pr| out << "<option value=\"#{pr}\" #{val == pr ? 'selected' : ''}>#{pr}</option>"}        
      out << '</select>'
      raw out
      #raw %Q{ <select name="probe[#{meth}]" type="text" size="15" value="" >#{options_from_collection_for_select(collection, id, text)} </select> }
    else
      raw %Q{ <span>#{val}</span> }
    end 
  end
end
