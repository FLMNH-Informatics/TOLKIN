# coding: utf-8

module CollectionsHelper
  
  def id_qualifier; text_field_or_text(:identification_qualifier) end
  def type_name; text_field_or_text(:type_name) end
  def type_status; text_field_or_text(:type_status) end

  def get_external_link( link_name, collection)
    external_links  = { :herbarium => "http://sweetgum.nybg.org/ih/"
    }
    external_links[link_name] || external_links[link_name.intern]
  end

  def type_statuses
    [ [ '', 'none' ],
      [ 'Holotype', 'holotype' ],
      [ 'Isotype', 'isotype' ],
      [ 'Neotype', 'neotype' ],
      [ 'Lectotype', 'lectotype' ],
      [ 'Isolectotype', 'isolectotype' ],
      [ 'Syntype', 'syntype' ],
      [ 'Isosyntype', 'isosyntype' ],
      [ 'Paratype', 'paratype' ],
      [ 'Isoparatype', 'isoparatype' ],
      [ 'Isoneotype', 'isoneotype'],
      [ 'Non est Typus', 'non_est_typus' ],
      [ 'Type', 'type' ]
    ]
  end

  def locality_fields type
#    begin
    %{<table id="#{type}_dms_table" style="display:#{ @collection.lat_long_rep == 'DD' ? 'none' : 'block' }">
        <tr>
          <td class="value">#{text_field_or_text("#{type}_deg", { size: 5 })}°</td>
          <td class="value">#{text_field_or_text("#{type}_min", { size: 5 })}'</td>
          <td class="value">#{text_field_or_text("#{type}_sec", { size: 5 })}"</td>
          <td class="value">#{send("#{type}_dir_select")}</td>
        </tr>
      </table>
      <table id="#{type}_dd_table" style="display:#{ @collection.lat_long_rep == 'DD' ? 'block' : 'none'}">
        <tr>
          <td class="value">#{text_field_or_text("#{type}_dd")} decimal degrees</td>
        </tr>
      </table>
    }
#    rescue => e
#      debugger
#      e.to_s
#      'hello'
#    end
  end

  def locality_format
    begin
    case (interact_mode)
    when 'browse'
      case @collection.lat_long_rep.blank?
        when 'DMS' then 'Deg. Min. Sec.'
        when 'DD' then 'Decimal Degrees'
        else %{<span class='empty'>Not selected</span>}
      end
    when 'edit'
      %{<select id='lat_long_select' name='collection[lat_long_rep]'>
          <option value='DMS'#{@collection.lat_long_rep == 'DMS' ? ' selected' : ''}>Deg. Min. Sec.</option>
          <option value='DD'#{@collection.lat_long_rep == 'DD' ? ' selected' : ''}>Decimal Degrees</option>
        </select>
      }
    end
    rescue => e
      debugger
      'hello'
    end
  end

  def catalog_buttons options
    options.inject('') do |acc, button_options|
      acc \
      +(!button_options[:interact_mode] || button_options[:interact_mode] == interact_mode ?
        %{<div class="button active" value="#{button_options[:value]}">
            <table>
              <tr>
                <td>
                  <img src="/images/#{button_options[:img][:src]}"#{
                    ( button_options[:img][:size] ?
                      %{ style="width:#{
                        button_options[:img][:size].split('x')[0]
                        }px; height:#{
                        button_options[:img][:size].split('x')[1]
                        }px"
                      }
                      : ''
                    )
                  } />
                </td>
                <td>
                  <span>#{button_options[:value]}</span>
                </td>
              </tr>
            </table>
          </div>
        }
        : ''
      )
    end
  end

#  def collections_catalog_buttons
#    catalog_buttons([
#      { value: 'Create', img: { src: 'addnew.gif', size: '14x14' }, imode: 'edit' },
#      { value: 'Delete', img: { src: '16-em-cross.png' }, imode: 'edit'},
#      { value: 'Export', img: { src: 'report.png', size: '16x16' } }
#    ])
#  end


#PLANTS OF CHILE
#
#Taxon Nmae
#
#Country. State/province. County: Locality.
#fruiting / flowering.
#
#Collector #collection-number   Date: collection-start-date to collection-end-date
  def get_specimen_label
    specimen_label = ""
    specimen_label << (@collection.taxon.try(:name) || "")
    specimen_label << "<br/>"
    specimen_label << (@collection.country + ". ") if @collection.country
    specimen_label << (@collection.state_province  + ". ") if @collection.state_province
    specimen_label << (@collection.county + ": ") if(@collection.county && !@collection.county.empty?)
    specimen_label << (@collection.locality || "" + ".") if (@collection.locality && !@collection.locality.empty?)
    specimen_label << "<br/>"
    specimen_label << "fruiting" if @collection.fruiting
    specimen_label << "/ flowering" if( @collection.flowering && @collection.fruiting)
    specimen_label <<  "flowering" if( @collection.flowering && !@collection.fruiting)
    specimen_label <<  "<br/>"
    specimen_label << @collection.collector || ""
    specimen_label << (" #" + @collection.collection_number) if @collection.collection_number
    specimen_label << " Date:"
    specimen_label << (@collection.coll_start_date.to_s || "---")
    specimen_label << " to " + (@collection.coll_end_date.to_s || "---")
    specimen_label
  end

  def taxon_name_combo_box
    if(params[:action] == 'new')
      interact_mode && @interact_mode = 'edit'
    end
    if(request.xhr?)
      parent = Object.new
      def parent.id
        'viewport_window'
      end
    else
      parent = content_frame
    end
    @taxon_combo_box ||= Collections::TaxonComboBox.new({
      collection: @collection,
      context: self,
      parent: parent
    }).render_to_string
  end

  def elevation_unit_combo_box
    if(params[:action] == 'new')
      interact_mode && @interact_mode = 'edit'
    end
    @elevation_unit_combo_box ||= Collections::ElevationUnitComboBox.new({
      collection: @collection,
      context: self,
      parent: content_frame
    }).render_to_string
  end

  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end

  def collections_catalog
    Collections::Catalog.new({
      collection: @collections,
      context: self,
      parent: content_frame
    }).render_to_string
    #catalog('viewport_content_frame_collection_catalog', @requested, [        { :attribute => "collector", :width => 100 },        { :attribute => "collection_number", :label => "Collection Number", :width => 100 },        { :attribute => "taxon.label", :label => "Species Name", :width => 300 },        { :attribute => "country", :width => 100 }      ], :count => @count    )
  end


  def annotations_catalog
 
    Collections::AnnotationsCatalog.new({
      #annotations: Annotation.new,
      collection: @collection.annotations,
      context: self,
      parent: new_window
    }).render_to_string
    #catalog('viewport_content_frame_collection_catalog', @requested, [        { :attribute => "collector", :width => 100 },        { :attribute => "collection_number", :label => "Collection Number", :width => 100 },        { :attribute => "taxon.label", :label => "Species Name", :width => 300 },        { :attribute => "country", :width => 100 }      ], :count => @count    )
  end

  def image_gallery
    Collections::ImageGallery.new({
      collection: @collection,
      context: self,
      parent:  params[:action] == 'show' ? content_frame : new_window,
    }).render_to_string
  end

  def not_editable(detail)
    @collection.send(detail).to_s.blank? ? "<span class='empty'>None</span>" : "#{@collection.send(detail)}"
  end

  def form_action
    project_collection_path
  end

  

   def annotations_table_draw
        output="";
        case interact_mode
        when "browse"
            output+="<table border='1'><tr><td style='width:100px'><b>Taxon</b></td><td style='width:100px'><b>Determiner</b></td><td style='width:100px'><b>Date</b></td><td style='width:100px'><b>Institution</b></td></tr>"
              @collection.annotations.each do |record|
                output+="<tr><td>#{record.taxon}</td>"
                output+="<td>#{record.name}</td>";
                output+="<td>#{record.date}</td>";
                output+="<td>#{record.inst}</td></tr>";
              end

        when "edit"
          
            output+='<div id="collections_annotations">';
            output+='<input type="button" value="Add" onclick="addRowToTable();"/><input type="button" value="Remove" onclick="removeRowFromTable();"/>'
            output+='<table border="1" id="collection_tblSample">'
            output+='<tr><td style="width:200px"><b>Taxon</b></td><td style="width:200px"><b>Determiner</b></td><td style="width:100px"><b>Date</b></td><td><b>Institution</b></td></tr>';
            
            @collection.annotations.each_with_index do |record, i|
            output+='<tr><td><input type="text" name="annotation'+(i+1).to_s+'[taxon]" id="collection_txtRow'+(i+1).to_s+'_taxon" size="10" value='+record.taxon.to_s+'></input></td>';
              output+='<td><input type="text" name="annotation'+(i+1).to_s+'[name]" id="collection_txtRow'+(i+1).to_s+'_taxon" size="10" value='+record.name.to_s+'></input></td>';
              output+='<td><input type="text" name="annotation'+(i+1).to_s+'[date]" id="collection_txtRow'+(i+1).to_s+'_taxon" size="10" value='+record.date.to_s+'></input></td>';
              output+='<td><input type="text" name="annotation'+(i+1).to_s+'[inst]" id="collection_txtRow'+(i+1).to_s+'_taxon" size="10" value='+record.inst.to_s+'></input></td></tr>';
          end

        output+="</table></div>";
        end
   end
  

  def form_action
    project_collection_path(params[:project_id], params[:id])
  end
  
  def save_button
    (interact_mode == 'edit' ) ? 'display: block' : 'display: none'
  end

  def text_field_custom(fieldName, size)
    if(fieldName=="longitude" || fieldName=="latitude")
            value = truncate_to_6(@collection[fieldName])
    else
            value = @collection[fieldName]
    end
    case interact_mode
    when 'browse'
      if !value || value.to_s.strip() == ''
        "<span class='empty'>None</span>"
      else
        "<span class='link' >#{value}</span>";
      end
    when  'edit'
        "<input type='text' name='collection[#{fieldName}]' value='#{value}' size='#{size}'/>"
    end
  end
  
  def big_text_field_or_text(fieldName)
   text_field_custom(fieldName, 15)
  end

  def text_field_or_text(fieldName, options = {})
    text_field_custom(fieldName, options[:size] || 10)
  end

  def large_text_field_or_text(fieldName)
    text_field_custom(fieldName, 65)
  end

  def date_field(attribute)
    split_date = {};
    if(@collection[attribute])
      date_match = @collection[attribute].to_s.match(/(\d{4})\-(\d{2})\-(\d{2})/)
      split_date = { :Y => date_match[1], :mm => date_match[2], :dd => date_match[3] }
    else
      split_date = { :Y => '', :mm => '', :dd => '' }
    end
    date_obj = DateFieldDate.new(split_date)

    case interact_mode
    when  'browse'
        [ split_date['Y'], split_date['mm'], split_date['dd'] ].compact().join(' / ')
    when 'edit'
            objectName = 'collection';
            render :partial => "forms/date_field" ,  :locals => { :object_name => objectName, :attribute_name => attribute, :date => date_obj  }
    end
  end

  def link
    ''
  end
  def coll_start_date_field
    date_field('coll_start_date')
  end

  
  def coll_end_date_field
    date_field('coll_end_date')
  end

  def verbatim_coll_date_field
    text_field_or_text('verbatim_coll_date')
  end

  def date_trans_field
    text_field_or_text('date_trans')
  end

  def dir_select(fieldName, directions)
    value = @collection[fieldName]
    case interact_mode
    when 'browse'
       if !value || value.to_s.strip() == ''
        "<span class='empty'>None</span>"
      else
         value.upcase
      end
    when 'edit'
      "<select name='collection[lat_dir]'>"+
        "<option value='n' "+(value==directions.first ? 'selected' : '' )+">"+directions.first.to_s.upcase+"</option>"+
                "<option value='s' "+(value==directions.second ? 'selected' : '' )+">"+directions.second.to_s.upcase+"</option>"+
      "</select>"
    end
  end

  def lat_dir_select
      dir_select('lat_dir' , ['n' , 's' ])
  end

  def long_dir_select
    dir_select('long_dir' , ['e' , 'w' ])
  end

  def checkbox_or_text(fieldName)
    isChecked =  @collection[fieldName] ? "checked='checked'" : ''
    case interact_mode
    when 'browse'
      if !@collection[fieldName] || @collection[fieldName].to_s.strip() == ''
        "<span class='empty'>None</span>"
      else
        "<span class='link' >#{@collection[fieldName]}</span>";
      end
    when  'edit'
       "<input type='checkbox' name='collection[#{fieldName}]' #{isChecked} value='1' />"
    end
  end


  def new_window
    @new_window ||= Templates::Window.new({ parent: viewport && @viewport, context: self })
  end
#  def not_editable(fieldName)
#    if @collection[fieldName].respond_to?(:label)
#      value = @collection[fieldName].label
#    else
#      value = @collection[fieldName].to_s
#    end
#     if !value || value.to_s.strip() == ''
#        "<span class='empty'>None</span>"
#      else
#        "<span class='link' >#{value}</span>";
#      end
#  end

   def text_area_or_text(fieldName)
     text_area_custom(fieldName,20)
   end

   def large_text_area_or_text(fieldName)
     text_area_custom(fieldName,75)
   end

   def text_area_custom(fieldName,size)
     case interact_mode
    when 'browse'
      if !@collection[fieldName] || @collection[fieldName].to_s.strip() == ''
        "<span class='empty'>None</span>"
      else
        "<span class='link' >#{@collection[fieldName]}</span>";
      end
    when  'edit'
      "<textarea rows='2' cols='#{size}' name='collection[#{fieldName}]' value='#{@collection[fieldName]}' size='10'>#{@collection[fieldName]}</textarea>"
    end
   end

   def truncate_to_6(anynum)
        if(!anynum.blank?)
          num_str=anynum.to_s
          dec_pos = num_str.index('.')
          if (!dec_pos)
            num_str + ".000000";
          else
            num_str += "000000";
            num_str[0,dec_pos+7]
          end
        else
          nil
        end
   end
end
