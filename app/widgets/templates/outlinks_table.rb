module Templates
  class OutlinksTable < Widget
    def initialize params
      @taxon ||= params[:taxon]
      super
    end

    def to_s
      %{
        <table class="outlinks-table widget" id="#{id}" border="1" style="border: 1px dotted #333">
          #{generate_row('TreeBASE', "TreeBASE", "treebase_logo.png")}
          #{generate_row("NCBI", "National Center for Biotechnology Information","NCBI_logo.png")}
          #{generate_row("uBio", "Indexing & Organizing Biological Names","uBio_logo.gif")}
          #{generate_row("GBIF", "Global Biodiversity Information Facility","GBIF_logo.jpg")}
          #{generate_row("EOL", "Encyclopedia Of Life","EOL_logo.jpg")}
          #{generate_row("JSTOR", "JSTOR Plant Science","jstor_logo.gif")}
          #{generate_row("IPNI", "International Plant Names Index","IPNI_logo.gif")}
          #{generate_row("Tropicos", "","Tropicos_logo.gif")}
        </table>
      }
    end

    def generate_row (name, description, image_name)
      name_id = name.downcase + "_id"
      %{
        <tr class="#{_get_class_name(name)}" data-link="#{_get_external_link(name)}" >
          <td style="padding: 10px 10x 10px 10px;" align="center">
            <img alt="#{name}" src="/images/#{image_name}"/>
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
            <b>#{name}</b>
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
          #{
              if name == "TreeBASE"
                _treebase_links
              elsif name == "GBIF" && @taxon.gbif_id
                _gbif_links
              else
                description
              end
           }
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
            #{
              if (name=="uBio" || name=="NCBI" || name=="TreeBASE" || name=="GBIF" || name=="EOL")
                tag_str = _text_field_or_text(name_id, @taxon.try(name_id), 3)
                if (interact_mode == 'edit')
                  "ID:#{tag_str}" + search_button(name.downcase)
                else
                  tag_str
                end
              else
                ''
              end
            }
          </td>
        </tr>
      }
    end


    def _gbif_links
      str = ""
      if @taxon.gbif_id
        str += %(<a href="#{_get_external_link('GBIF')}" target="_blank">Default Portal</a>)
        str += ' | ';
        str += %(<a href="http://uat.gbif.org/species/#{@taxon.gbif_id}" target="_blank">Beta Portal</a>)
      end
      str
    end

    def _jstor_links
      str = %{<a href="#{_get_external_link('JSTOR')}" target="_blank">JSTOR Plant Science </a>}
      str+= ' | '
      str+= %{<a class="tolkin_jstor_widget">TOLKIN JSTOR Widget</a>}
      str
    end

    def _treebase_links
      link_table = ""
      unless @taxon.treebase_id.nil?
        link_table += %{
          <table id="treebase_links">
            <tr>
              <th>Trees</th>
              <td style="align:center;border:none;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexml", "tree")}">NeXML</a></td>
              <td style="align:center;border:none;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "rss1", "tree")}">List</a></td>
              <td style="align:center;border:none;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexus", "tree")}">nexus</a></td>
            </tr>
            <tr>
              <th>Matrices</th>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexml", "matrix")}">NeXML</a></td>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "rss1", "matrix")}">List</a></td>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexus", "matrix")}">nexus</a></td>
            </tr>
            <tr>
              <th>Studies</th>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexml", "study")}">NeXML</a></td>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "rss1", "study")}">List</a></td>
              <td style="align:center;"><a target="_blank" href="#{_treebaseUrl(@taxon.treebase_id, "nexus", "study")}">nexus</a></td>
            </tr>
          </table>
        }
      end
      link_table
    end

    def _treebaseUrl(treebase_id, format, schema)
      "http://treebase.org/treebase-web/search/taxonSearch.html?query=tb.identifier.taxon=Tx#{treebase_id}&format=#{format}&recordSchema=#{schema}"
    end

    def _get_class_name (name)
      case name
        when 'uBio' then 'ubio'
        when 'NCBI' then 'ncbi'
        when 'Tree Base' then 'treeBase'
        when 'treeBASE'  then 'treeBase'
        when 'EOL'       then 'eol'
        else ''
      end
    end

    def search_button type
      %{<input type="button" style="padding-left:0px;padding-right:0px;" data-outlink_type="#{type}" class="search_outlink" value="Find ID"/>}
    end

    def _get_external_link (name)
      case (name)
      when 'JSTOR'
        "http://plants.jstor.org/search?searchText=#{@taxon.name.split(' ').join('+')}"
        when 'GBIF'
          if @taxon.gbif_id
            "http://data.gbif.org/species/#{@taxon.gbif_id}/"
          else
            "http://data.gbif.org/search/#{@taxon.name.split(' ').join('+')}"
          end
      when 'Tropicos'
        "http://tropicos.org/NameSearch.aspx?name=#{@taxon.name.split(' ').join('+')}"
      when 'EOL'
        if @taxon.eol_id
          "http://eol.org/pages/#{@taxon.eol_id}/overview"
        else
          "http://www.eol.org/search?q=#{@taxon.name.split(' ').join('+')}"
        end
      when 'IPNI'
        "http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#{@taxon.name.split(' ').join('+')}&output_format=normal&query_type=by_query&back_page=query_ipni.html"
      when 'uBio'
        if (@taxon.ubio_id)
          "http://www.ubio.org/browser/details.php?namebankID=#{@taxon.ubio_id}"
        else
          "http://www.ubio.org/browser/search.php?search_all=#{@taxon.name.split(' ').join('+')}"
        end
      when 'NCBI'
        if (@taxon.ncbi_id)
          "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=#{@taxon.ncbi_id}"
        else
          "http://www.ncbi.nlm.nih.gov/taxonomy?term=#{@taxon.name.split(' ').join('+')}"
        end
      when 'TreeBASE'
        if (@taxon.treebase_id)
          "http://treebase.org/treebase-web/search/taxonSearch.html?query=tb.identifier.tree==#{@taxon.treebase_id.gsub("TB2:","")}"
        else
          %{http://treebase.org/treebase-web/search/taxonSearch.html?query=dcterms.title=="#{@taxon.name.split(' ').join('+')}"}
        end
      end
    end

    def _text_field_or_text (field_name, value, size, options = {})
      value || value = ''
      case interact_mode
      when 'browse'
        if (!value || value.blank?)
          "<span class='empty'>None</span>";
        else
          if(options['link_id'])
            "<span class='link' data-taxon-id='" + options['link_id'] + "'>" + value + "</span>";
          else
            value
          end
        end
      when 'edit'
        "<input type='text' size='#{size}' name='taxon[#{field_name}]' value='#{value || ''}' />"
      end
    end
  end
end