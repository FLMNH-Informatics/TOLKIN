module WindowsHelper


  def window_id(options = { })
    case [ options[:controller] || request[:controller], options[:action] || request[:action] ]
#    when [ "/molecular/bioentries"         , "show"  ] then "bioentry_details"
    when [ "/molecular/matrix/cells"       , "show"  ] then "mol_cell_details"
    when [ "/molecular/plastome/table/taxa", "index" ] then "edit_plastome_table_taxa"
    when [ "/molecular/plastome/table/taxa", "new"   ] then "add_taxon_window"
    else ""
    end
  end

  def window_title(options = { })
    case [ options[:controller] || request[:controller], options[:action] || request[:action] ]
#    when [ "/molecular/bioentries"         , "show"  ] then "Sequence Details"
    when [ "/molecular/matrix/cells"       , "show"  ] then "Cell Details"
    when [ "/molecular/plastome/table/taxa", "index" ] then "Add / Remove / Move Taxa"
    when [ "/molecular/plastome/table/taxa", "new"   ] then "Add Taxon"
    else ""
    end
  end

  def window_url(window_name, params = { })
    #case window_name
#    when :bioentry_details then project_bioentry_path(params)
    #else
    ""
    #end
  end
end
