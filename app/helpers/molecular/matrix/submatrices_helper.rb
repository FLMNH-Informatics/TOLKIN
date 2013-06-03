module Molecular::Matrix::SubmatricesHelper
  include Molecular::MatricesHelper

  def submatrix_name_field
    interact_mode.to_s == "browse" ?
      @submatrix.name
    :
      %(<input id="submatrix_name" type="text" value="#{@submatrix.name}" />)
  end

  def otu_conditions
    conds = case params["action"]
      when "edit" then "otu_id not in (#{@submatrix.submatrix_otus.map{|so|so.otu_id}.join(',')})"
      when "new"  then ''
    end
    conds
  end

  def marker_conditions
    conds = case params["action"]
      when "edit" then  "marker_id not in (#{@submatrix.submatrix_markers.map{|sm|sm.marker_id}.join(',')})"
      when "new"  then  ''
    end
    conds
  end

  def otu_count_select
    'test'
  end

  def marker_count_select
    'test'
  end

end
