

module TolkinExporter

  def display_column_names
    # def resource    must be defined on controller
    @res = resource
    @table_col = @res.column_names.reject{|col_name| col_name.include?('_id') ?   col_name == 'taxon_id' ? false : true   : false}

    render :partial => "shared/tolkin_export_column_list" , :locals => {:controller_name => controller_name}
  end
end