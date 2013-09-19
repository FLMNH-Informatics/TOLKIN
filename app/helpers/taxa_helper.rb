# coding: utf-8
module TaxaHelper

  def outlinks_type_name
    case params[:outlink_type]
      when 'ncbi'     then 'NCBI'
      when 'treebase' then 'treeBASE'
      when 'ubio'     then 'uBio'
      when 'gbif'     then 'GBIF'
      when 'eol'      then 'EOL'
        else params[:outlink_type] | 'Outlink'
    end
  end

  def jstor_widget
    %{<script type="text/javascript"
              src="http://plants.jstor.org/page/search/search_widget.js">
      </script>
      <script type="text/javascript">

        JstorPlantsWidgets.init()
      </script>
      <div id="JSTOR-PLANTS"
           query="Euphorbia peplus"
           iWidth="700"
           iHeight="800"
           records="8"
           wmetadata="true"
           wresTypes="ALL"
           wthumbnail="true"
           wtitle="true"  />}
  end

  def taxon_outlink type, id
    case type
      when 'ubio'
        %{http://www.ubio.org/browser/details.php?namebankID=#{id}}
      when 'ncbi'
        %{http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=#{id}}
      when 'treebase'
        %{http://treebase.org/treebase-web/search/taxonSearch.html?query=tb.identifier.taxon=Tx#{id}}
      when 'gbif'
        %{http://data.gbif.org/species/#{id}/}
      when 'eol'
        %{htt[://eol.org/pages/#{id}/overview}
    end
  end

  def set_perm_view_color(permissions, type)
    perm_type =
      case type
        when 'view' then :visible
        when 'edit' then :editable
        when 'delete' then :deletable
        when 'permit' then :permissible
      end
    true_array, false_array =
      permissions.partition do |perm|
        perm.send(perm_type)
      end
    if true_array.empty?
      'red'
    elsif false_array.empty?
      'green'
    else
      'yellow'
    end
  end

  def action_list_id
    'taxa_action_list'
  end

  def chromosome_number;         text_field_or_text('chromosome_number', 50)                       end
  def comments;                  text_area_or_text('comments', { rows: 4, cols: 55})               end
  def common_names;              text_area_or_text('commonname', { rows: 4, width: 625 })          end
  def conservation_status;       text_area_or_text('conservation_status', { rows: 2, cols: 55 })   end
  def description;               text_area_or_text('description', { rows: 7, cols: 55})            end
  def general_distribution;      text_area_or_text('general_distribution', {rows: 5, width: 675})  end
  def habitat;                   text_area_or_text('habitat', { rows: 3, cols: 55 })               end
  def neotype;                   text_field_or_text('neotype', 70)                                 end
  def notes;                     text_area_or_text('notes', rows: 4, cols: 70)                     end
  def phylogenetic_relationship; text_area_or_text('phylogenic_relationship', rows: 3, width: 450) end
  def publication_name;          text_field_or_text('publication', 55)                             end
  def toxicity;                  text_field_or_text('toxicity', 50)                                end
  def type_collection;           text_field_or_text('type_collection', 70)                         end
  def type_date;                 text_field_or_text('type_date', 30)                               end
  def type_herbaria;             text_area_or_text('type_herbaria', {rows: 2, cols: 80})           end
  def type_locality;             text_field_or_text('type_locality', 70)                           end
  def type_species;              text_field_or_text('type_species', 70)                            end
  def uses;                      text_area_or_text('uses', rows: 3, width: 450)                    end
  
  def is_selected section_name
    if section_name == 'nomenclature'
      'selected'
    else
      ''
    end
  end

  def display section_name
    if section_name == 'nomenclature'
      'block'
    else
      'none'
    end
  end

  def protologue_output
    
    if interact_mode == 'browse'
      return 'will be a link to protologue'
    else
      return "<a href='#'>Upload Protologue File</a>"
    end
  end
  
  def taxa_catalog
     Taxa::Catalog.new(
      collection: @taxa,
      context: self,
      parent: content_frame
    ).render_to_string
  end

  def node_name_element(taxon)    
    div_classes = [ 'tree_view_node_name' ]
    div_classes.push 'accepted_name' if taxon.namestatus.try(:status) == 'accepted_name'
    span_class = current_selection.to_s == taxon ? " class='selected'" : ''
    return "<div class='#{div_classes.join(' ')}'><span#{span_class}>#{taxon.name}</span></div>"
  end


  def form_action_for_new
    "/projects/"+params[:project_id]+"/taxa"
  end

  def form_action
    project_taxon_path
  end

#  def current_project
#    @current_project
#  end

  def images
    Taxa::ImageGallery.new({
      context: self,
      parent: tabbed_box,
      taxon: @taxon
    }).render_to_string
  
#    if(interact_mode=="browse")
#    output=""
#    end
#    if(interact_mode=="edit")
#      output ='<div style="margin: 0px 10px;"><div><form id="imageupload" action="/images">';
#      output+="<input id='options_image_type' type='hidden' value='Taxon' name='options[image_type]'/>"
#      output+="<input id='options_id' type='hidden' value='"+(@taxon.id.to_s)+"' name='options[id]'/>"
#      output+='<div style="display: inline; border: solid 1px #7FAAFF; background-color: #C5D9FF; padding: 2px;">';
#      output+='<span id="spanButtonPlaceholder"></span></div></form></div>';
#      output+='<div id="divFileProgressContainer" style="height: 75px;"></div><div id="thumbnails"></div></div>';
#    end
#    output
  end
  
  def render_images_collection
    render :partial => 'shared/image_display_for_species_page.html.erb', :collection => @taxon.image_links 
  end

  def add_citation_button
    interact_mode == 'browse' ? '' : "<input type='button' class='citation_search' value='Add Citation' />"
  end

  def button
    if(interact_mode=="edit")
      '<input type="submit" value="save" /><br/>'
    end
  end

  def buttons_classes
    interact_mode == 'edit' ? ' active' : ''
  end

  def expander_for(node)
    if(node.has_descendants?)
#      if(@selected_taxon && @selected_taxon.descendant_of?(node))
#        "‒"
#      else
        "+"
#      end
    else
      ""
    end
  end

    def header
#    str=""
#    temp1=""
#    temp2=""
#    temp3=""
#    temp4=""
#    temp1=@taxon.parent.try(:parent).blank? ? "" : @taxon.parent.parent.name
#    str+=temp1
#    temp2=@taxon.parent.blank? ? "" :@taxon.parent.name
#    if temp1=="" || temp2=="" then str+="" else str+=" > " end
#    str+=temp2
#    temp3+=@taxon.sub_genus.blank? ? "" :@taxon.sub_genus
#    if temp2=="" || temp3=="" then str+="" else str+=" > " end
#    str+=temp3
#    str+=@taxon.section.blank? ? "" : "Section "+@taxon.section
#    if temp3=="" || temp4=="" then str+="" else str+=" > " end
#    str+=temp4
  end
  
  def name
    str = ""
    if @taxon.name.empty?
      fail "Taxon name is an empty string"

    else
     
      if (interact_mode=="browse")
          str+=%{
            <span style='font-size: 16px; font-weight: bold;'>#{@taxon.name} </span>&nbsp;
            #{@taxon.author.blank? && @taxon.infra_author.blank? ? "" : " #{@taxon.author || @taxon.infra_author}, "}
            #{@taxon.publication.blank? ? "" : "<span class='protologue_publication_name'>#{@taxon.publication}</span> "}
            #{@taxon.volume_num.blank? ? "" : "#{@taxon.volume_num}: "}
            #{@taxon.pages.blank? ? "" : "#{@taxon.pages}. " }
            #{@taxon.publication_date.blank? ? "" : "#{@taxon.publication_date}." }
            <br /><br />
          }
      else
          str+="<input type='text' size='50' name='taxon[name]' value='#{@taxon.name}' />"
          str+="<table>"
          str+="<tr><td>Author:</td><td colspan='3'>"
          str+="<input type='text' style='width:100%' name='taxon[author]' value='#{@taxon.author}' />"+
          "</td></tr>"+
          "<tr>"+
            "<td>Publication:</td>"+
            "<td><input type='text' size='40' name='taxon[publication]' value=\"#{@taxon.publication}\" /></td>"+
            "<td style='padding-left:5px'>Volume:</td>"+
            "<td><input type='text' size='5' name='taxon[volume_num]' value='#{@taxon.volume_num}' /></td>"+
          "</tr>"+
          "<tr>"+
            "<td style='padding-left:5px'>Pages:</td>"+
            "<td><input type='text' size='8' name='taxon[pages]' value='#{@taxon.pages}' /></td>"+
            "<td style='padding-left:5px'>Year:</td>"+
            "<td><input type='text' size='10' name='taxon[publication_date]' value='#{@taxon.publication_date}' /></td>"+
          "</tr>"+
          "<tr><td>Infra Name:</td><td>"
          str+="<input type='text' style='width:100%' name='taxon[infra_name]' value='#{@taxon.infra_name}' />"
          str+="</td><td style='padding-left:5px'>Infra Author:</td><td>"
          str+="<input type='text' style='width:100%' name='taxon[infra_author]' value='#{@taxon.infra_author}' />"
          str+="</td></tr></table>"
          
      end       
        str
    end
    str
  end

  def tabbed_box_id
    'viewport_content_frame_taxa_tabbed_box'
  end

  def accepted_name_display
   ( (@taxon.namestatus && @taxon.namestatus.status == 'synonym') || (@taxon.namestatus && @taxon.namestatus.status == 'basionym')) ? '' : 'display: none'
  end

  def new_window
    @new_window ||= Taxa::NewWindow.new({ parent: viewport && @viewport, context: self })
  end

  def general_window
    @general_window ||= General::Window.new
  end

  #TODO: fixme - should be using ComboBox widget class
  def accepted_name_combo_box
    parent = request.xhr? ? general_window : content_frame
    @accepted_name_combo_box ||= Taxa::AcceptedNameComboBox.new({ taxon: @taxon, parent: parent, context: self })
  end

  def parent_combo_box
    parent = request.xhr? ? general_window : content_frame
    @parent_combo_box ||= Taxa::ParentComboBox.new({ taxon: @taxon, parent: parent, context: self })
  end



  def status
        output=""
          if(interact_mode=='browse')
                if(@taxon.namestatus == "")
                    output+="<span class='empty'>None</span>"
                end
                if(@taxon.namestatus)
                    output+= @taxon.namestatus.status
                end
          else
            output+="<select id='namestatus_select' name='taxon[namestatus_id]'>" 
            output+="<option value='13' " + (@taxon.namestatus && @taxon.namestatus.id == 13 ? "selected='selected'" : '') + ">None</option>"
            output+="<option value='1' " + (@taxon.namestatus && @taxon.namestatus.id == 1 ? "selected='selected'" : '') + ">Accepted Name</option>"
            output+="<option value='2' " + (@taxon.namestatus && @taxon.namestatus.id == 2 ? "selected='selected'" : '') + ">Basionym</option>"
            output+="<option value='3' " + (@taxon.namestatus && @taxon.namestatus.id == 3 ? "selected='selected'" : '') + ">Synonym</option>"
            output+="<option value='4' " + (@taxon.namestatus && @taxon.namestatus.id == 4 ? "selected='selected'" : '') + ">Doubtful synonym</option>"
            output+="<option value='5' " + (@taxon.namestatus && @taxon.namestatus.id == 5 ? "selected='selected'" : '') + ">Invalid</option>"
            output+="<option value='6' " + (@taxon.namestatus && @taxon.namestatus.id == 6 ? "selected='selected'" : '') + ">Misapplied name</option>"
            output+="<option value='7' " + (@taxon.namestatus && @taxon.namestatus.id == 7 ? "selected='selected'" : '') + ">Spelling variant</option>"
            output+="<option value='8' " + (@taxon.namestatus && @taxon.namestatus.id == 8 ? "selected='selected'" : '') + ">Nom nud</option>"
            output+="<option value='9' " + (@taxon.namestatus && @taxon.namestatus.id == 9 ? "selected='selected'" : '') + ">Nom illeg</option>"
            output+="<option value='10' " + (@taxon.namestatus && @taxon.namestatus.id == 10 ? "selected='selected'" : '') + ">Nom nov</option>"
            output+="<option value='11' " + (@taxon.namestatus && @taxon.namestatus.id == 11 ? "selected='selected'" : '') + ">Unpublished</option>"
            output+="<option value='12' " + (@taxon.namestatus && @taxon.namestatus.id == 12 ? "selected='selected'" : '') + ">Unplaced</option>"
            output+="</select>";
          end
      output    
  end

  def text_area_or_text(detail, html_options)
    rows  = html_options[:rows]  || 4
    width = html_options[:width] || 450
    str=""
    if(interact_mode=="browse")
      if(@taxon[detail].blank?) 
        str += "<span class='empty'>None</span>"
      else
        str += "<div style='width:#{width}px' class='value'>"+@taxon[detail]+"</div>"
      end
    else
      str+="<textarea name='taxon[#{detail}]' rows='#{rows}' style='width:#{width}'>"+(@taxon[detail].blank? ? "" :((@taxon[detail].include? "<br/>")?@taxon[detail].gsub("<br/>","\r"):@taxon[detail])).strip+"</textarea>"
    end
    str
  end

  

  def synonyms_table
    Taxa::SynonymsCatalog.new({
      taxon:   @taxon,
      parent:  tabbed_box,
      context: self
    }).render_to_string
  end

#  def synonyms_table
#    str=""
#    synonyms = @taxon.synonyms.all
#    if synonyms.empty?
#      str+="<span class='empty'>  No synonyms </span>"
#    else
#      total = synonyms.count
#      for i in 0..total-1 do
#        str += "<i>"+synonyms[i].name+"</i>"
#        synonyms[i].author.blank? ? str+="" : str+=" "+ synonyms[i].author
#        synonyms[i].publication.blank? ? str+="" : str+=", "+ synonyms[i].publication
#        synonyms[i].year.blank? ? str+="" : str+= ", " + synonyms[i].year
#        str += "<br>"
#      end
#      str
#    end
#  end

  def taxon_id
    @taxon.id
  end

  def add_citation
    
  end

  def notes_section
    if current_user.public_user?
      ''
    else
      %{<form action="#" class="species_page_form">
          <table><tr><td>Notes:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>#{notes}</td></tr></table>
        </form>
      }
    end
  end

  def citation_display_name (citation)
    citation.display_name
  end

  def citations_data
    unless @taxon.citations.empty?
      render partial: 'shared/list_citations_taxa', collection: @taxon.citations.sort{|c1, c2| "#{c1.contributors.first.try(:name) ||''}" <=> "#{c2.contributors.first.try(:name) ||''}" }, as: :citation
    else
      "<span class='empty'>  No citations </span>"
    end
  end

  def outlinks
    Taxa::TaxonOutlinksTable.new(taxon: @taxon, parent: tabbed_box, context: self)
  end

  def citation_delete
    if interact_mode == "edit"
      %(<img class="delete_citation" src="/images/delete.gif" alt="delete citation" width="12px" height="12px" />      )
    else
      ''
    end
  end

  def delete_citation_path
    delete_citation_project_taxon_path(params[:project_id], params[:id])
  end

#  def project_id
#    params[:project_id]
#  end

  def tabbed_box
    @tabbed_box ||= 
      Taxa::TabbedBox.new({
        parent: content_frame,
        context: self
      })
  end

  def collections_catalog
    Taxa::CollectionsCatalog.new({
      taxon:   @taxon,
      parent:  tabbed_box,
      context: self
    }).render_to_string
  end

   def collections_table

    if @taxon.collections.empty?
      "<span class='empty'>  No collections </span>"
    else
      columns = [ { :attribute => :collector, :width => 100 }, { :attribute => :collection_number, :width => 100},
        { :attribute => :country, :width => 100 } , { :attribute => :institution_code, :width => 100 } ]

      render(:partial => "widgets/catalog", :locals => {

          :catalog_id => "collections_check_list",
          :column_headings => columns.collect { |column| "<th style='width: #{column[:width].to_s}px'>#{column[:label] || column[:attribute].to_s.gsub(/_/, " ").capitalize}</th>" }.join(''),
          :nav_style => "width: " + columns.inject(48) { |acc, column| acc + column[:width] }.to_s + "px",
          :entries => @taxon.collections[0, 10].inject('') { |acc, collection|
            acc += render(:partial =>  "widgets/catalogs/entry", :locals => {
                :entry => collection,
                :entry_class => cycle('even', 'odd'),
                :column_data => columns.collect { |column| "<td style='width: #{column[:width].to_s}px'>#{collection.try(column[:attribute].to_sym)}</td>" }.join('')
              })
          },
          :left_inactive => "inactive", :right_inactive => @taxon.collections.count <= 10 ? "inactive" : "active",
          :start_index => "1", :count => @taxon.collections.count,
          :end_index => @taxon.collections.count > 10 ? "10" : @taxon.collections.count,
          :filters => nil
         })
          
    end
  end

   def molecular_data
     samples=@taxon.dna_samples.all
    if samples.empty?
      "<span class='empty'>  No DNA samples </span>"
    else
       i=0
      url = ""
      str = "DNA Sample(s): "
      method ="get"
      total = samples.count
      for i in 0..total-1 do
        #turn off links for public user
        url = "/projects/" + params[:project_id] + "/dna_samples/" + samples[i].id.to_s
        str += current_user.username == 'public' ? samples[i].id.to_s : "<a target='_blank' href='#{url}'>#{samples[i].id.to_s}</a>"
        if(i<total-1)
         str += ", "
        end
      end
       str
    end
  end

  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end

  def editors
    text_field_or_text('editors', 50)
  end

  def render_collections_if_not_empty(collections)
    unless collections.empty?
      return "<ul id='collections_list'>#{render :partial => "list_collections", :collection => collections}</ul>"
    else
      return 'No Collections'
    end
  end

#  def render_citations_if_not_empty(citations, taxon, project)
#    unless citations.empty?
#      return render(:partial => "/shared/list_citations", :collection => citations, :locals => {:obj => taxon, :url_options => { :controller => :taxa, :project => project, :id => taxon.id }})
#    else
#      #No Citations
#      return ''
#    end
#  end

  #to check if the taxon node is selected on the client, this is used to select the children too when node is expanded(plus is clicked)
  def get_class(tax)
    return (tax.selected? && "tn sel") || "tn"
  end

  def get_external_link( link_name, taxon)
    external_links  = { :TROPICOS => "http://mobot.mobot.org/cgi-bin/search_vast?NAME=#{taxon.name.split('+')}",
      :IPNI => "http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#{taxon.name.split('+')}&output_format=normal&query_type=by_query&back_page=query_ipni.html",
      :GBIF => "http://data.gbif.org/search/#{taxon.name}"
    }
    external_links[link_name] || external_links[link_name.intern]
  end

  def tree_view
    Taxa::TreeView.new({
      context: self, 
      parent: content_frame,
      root_taxa: @root_taxa
    }).render_to_string
  end

  private

  def author_and_protologue
    atts = @taxon
    case interact_mode.to_s
      when 'edit'
        auth = "<input type='text' style='width: 100%' name='taxon[author]' #{!@taxon.author.blank? ? "value='#{@taxon.author}'" : ''} />"
        pub  = !@taxon.publication.blank? ?
          "<input type='text' size='15' name='taxon[publication]' value='#{@taxon.publication}' />" 
          : "<input type='text' size='15' name='taxon[publication]' />"
        vol  = !@taxon.volume_num.blank? ?
          "<input type='text' size='5' name='taxon[volume_num]' value='#{@taxon.volume_num}' />" 
          : "<input type='text' size='5' name='taxon[volume_num]' />"
        pag  = !@taxon.pages.blank? ?
          "<input type='text' size='10' name='taxon[pages]' value='#{@taxon.pages}' />"
          : "<input type='text' size='10' name='taxon[pages]' />"
        y = !@taxon.publication_date.blank? ?
          "<input type='text' size='13' name='taxon[publication_date]' value='#{@taxon.publication_date}' />"
          : "<input type='text' size='13' name='taxon[publication_date]' />"
        inn = "<input type='text' style='width: 100%' name='taxon[infra_name]' #{!@taxon.infra_name.blank? ? "value='#{@taxon.infra_name}'" : ''} />"
        ina = "<input type='text' style='width: 100%' name='taxon[infra_author]' "+((atts.infra_author && !atts.infra_author.blank?) ?  "value='"+atts.infra_author+"'" : '') + " />";
        authProto =
          "<table><tr></tr>"+
            "<tr>"+
              "<td>Author: </td><td colspan='3'>"+auth+"</td>"+
            "</tr>"+
            "<tr>"+
              "<td>Infra Name: </td><td colspan='3'>"+inn+"</td>"+
              "<td>Infra Author: </td><td colspan='3'>"+ina+"</td>"+
            "</tr>"+
            "<tr>"+
              "<td>Publication: </td><td>"+pub+"</td>"+
              "<td>Volume: </td><td>"+vol+"</td>"+
              "<td>Pages: </td><td>"+pag+"</td>"+
              "<td>Year: </td><td>"+y+"</td>"+
            "</tr>"+

          "</table>";
      when 'browse'
        authPub =
        [ (atts.author && !atts.author.blank()) ? atts.author : null,
          (atts.publication && !atts.publication.blank()) ? "<span class='protologue_publication_name'>"+atts.publication+".</span>" : null
        ].compact().join(', ')

       authProto =
        [ authPub         && !authPub.blank()         ? authPub         : null,
          atts.volume_num && !atts.volume_num.blank() ? atts.volume_num : null,
          atts.pages      && !atts.pages.blank()      ? atts.pages      : null,
          atts.publication_date       && !atts.publication_date.blank()       ? atts.publication_date       : null
        ].compact().join(' ')
    end
    auth_proto
  end
  
  
end
