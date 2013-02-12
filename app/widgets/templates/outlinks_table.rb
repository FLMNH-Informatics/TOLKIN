module Templates
  class OutlinksTable < Widget
    def initialize params
      @taxon ||= params[:taxon]
      super
    end

    def to_s
      %{
        <table class="outlinks-table widget" id="#{id}" border="1" style="border: 1px dotted #333">
          #{generate_row("GBIF", "Global Biodiversity Information Facility","GBIF_logo.jpg")}
          #{generate_row("JSTOR", "JSTOR Plant Science","jstor_logo.gif")}
          #{generate_row("IPNI", "International Plant Names Index","IPNI_logo.gif")}
          #{generate_row("EOL", "Encyclopedia Of Life","EOL_logo.jpg")}
          #{generate_row("NCBI", "National Center for Biotechnology Information","NCBI_logo.png")}
          #{generate_row("uBio", "","uBio_logo.gif")}
          #{generate_row("Tropicos", "","Tropicos_logo.gif")}
        </table>
      }
    end

    def generate_row (name, description, image_name)
      %{
        <tr class="#{_get_class_name(name)}" data-link="#{_get_external_link(name)}" >
          <td style="padding: 10px 10x 10px 10px;" align="center">
            <img alt="#{name}" src="/images/#{image_name}"/>
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
            <b>#{name}</b>
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
            #{description}
          </td>
          <td style="padding: 10px 10px 10px 10px; vertical-align:middle" >
            #{
              if (name=="uBio" || name=="NCBI" || name=="Tree Base")
                tag_str =
                  case (name)
                    when "uBio"
                      _text_field_or_text('ubio_id', @taxon.ubio_id, 5)
                    when "NCBI"
                      _text_field_or_text('ncbi_id', @taxon.ncbi_id, 5)
                    when "Tree Base"
                      _text_field_or_text('treebase_id', @taxon.treebase_id, 5)
                  end
                if (interact_mode == 'edit')
                  "ID:#{tag_str}"
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

    def _get_class_name (name)
      case name
        when 'uBio' then 'ubio'
        when 'NCBI' then 'ncbi'
        when 'Tree Base' then 'treeBase'
        else ''
      end
    end

    def _get_external_link (name)
      case (name)
      when 'JSTOR'
        "http://plants.jstor.org/search?searchText=#{@taxon.name.split(' ').join('+')}"
      when 'GBIF'
        "http://data.gbif.org/search/#{@taxon.name.split(' ').join('+')}"
      when 'Tropicos'
        "http://tropicos.org/NameSearch.aspx?name=#{@taxon.name.split(' ').join('+')}"
      when 'EOL'
        "http://www.eol.org/search?q=#{@taxon.name.split(' ').join('+')}"
      when 'IPNI'
        "http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#{@taxon.name.split(' ').join('+')}&output_format=normal&query_type=by_query&back_page=query_ipni.html"
      when 'uBio'
        if(interact_mode == 'browse')
          if (@taxon.ubio_id)
            "http://www.ubio.org/browser/details.php?namebankID=#{@taxon.ubio_id}"
          else
            "http://www.ubio.org/browser/search.php?search_all=#{@taxon.name.split(' ').join('+')}"
          end
        else
          ''
        end
      when 'NCBI'
        if (interact_mode == 'browse')
          if (@taxon.ncbi_id)
            "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=#{@taxon.ncbi_id}"
          else
            "http://www.ncbi.nlm.nih.gov/taxonomy?term=#{@taxon.name.split(' ').join('+')}"
          end
        else
          ""
        end
      when 'Tree Base'
        if (@taxon.treebase_id)
          "http://treebase.nescent.org/treebase-web/search/taxonSearch.html?query=tb.identifier.tree=#{@taxon.treebase_id.gsub("TB2:","")}"
        else
          "http://treebase.nescent.org/treebase-web/search/taxonSearch.html?term=#{@taxon.name.split(' ').join('+')}"
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