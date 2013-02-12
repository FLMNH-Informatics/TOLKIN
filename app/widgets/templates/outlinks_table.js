//= require <widget>
//= require <lowpro>

Module('Templates', function() {
  JooseClass('OutlinksTable', {
    isa: Widget,
    isAbstract: true,
    has: {
      parent:        { is: 'ro', required: true, nullable: false },
      context:       { is: 'ro', required: true, nullable: false },
      taxon:         { is: 'ro', required: true, nullable: false }
    },
    methods: {
      onClick: function(event) {
        Event.delegate({
          'tr': function(event) {
            if(event.element().getAttribute('type')!="text" && event.element().up('tr').readAttribute('data-link') != "") {
              window.open(event.element().up('tr').readAttribute('data-link'),"_blank");
            }
          }
        }).bind(this)(event);
      },

      onMouseover: function(event) {
        if(this._inARow(event.element())) {
          event.element().up('tr').addClassName('highlighted');
        }
      },
      onMouseout: function(event) {
        if(this._inARow(event.element())) {
          event.element().up('tr').removeClassName('highlighted');
        }
      },

      render: function() {
        var renderString = this.renderToString();
        $(this.id()).replace(renderString);
      },

      renderToString: function() {
        var str="";
        str+='<table class="outlinks-table widget" id="'+this.id()+'" border="1" frame="box" rules="rows" style="border:1px dotted">'
        str+=this._generateRow("GBIF", "Global Biodiversity Information Facility","GBIF_logo.jpg");
        str+=this._generateRow("JSTOR", "JSTOR Plant Science","jstor_logo.gif");
        str+=this._generateRow("IPNI", "International Plant Names Index","IPNI_logo.gif");
        str+=this._generateRow("EOL", "Encyclopedia Of Life","EOL_logo.jpg");
        str+=this._generateRow("NCBI", "National Center for Biotechnology Information","NCBI_logo.png");
        str+=this._generateRow("uBio", "","uBio_logo.gif");
        //           str+=this._generateRow("Tree Base", "","treebase.gif");
        str+=this._generateRow("Tropicos", "","Tropicos_logo.gif");
        
        str+='</table>'
        return str;
      },

      _generateRow: function(name,description,image_name) {
        var str=""
        str+='<tr class="'+this._getClassName(name)+'" data-link="'+this._getExternalLink(name)+'" >'
        str+='<td style="padding: 10px 10px 10px 10px;" align="center">'
        str+='<img alt="'+name+'" src="/images/'+image_name+'"/>'
        str+='</td>'
        str+='<td style="padding: 10px 10px 10px 10px; vertical-align:middle" >'
        str+='<b>'+name+'</b>'
        str+='</td>'
        str+='<td style="padding: 10px 10px 10px 10px; vertical-align:middle" >'
        str+=description
        str+='</td>'
        str+='<td style="padding: 10px 10px 10px 10px; vertical-align:middle">'
        if(name=="uBio"||name=="NCBI" || name=="Tree Base")
        {
          var tag_str = "";

          switch(name)
          {
            case "uBio":
              tag_str = this._textFieldOrText('ubio_id', this.taxon().attributes().ubio_id,5);
              break;
            case "NCBI":
              tag_str = this._textFieldOrText('ncbi_id', this.taxon().attributes().ncbi_id,5);
              break;
            case "Tree Base":
              tag_str = this._textFieldOrText('treebase_id', this.taxon().attributes().treebase_id,5);
          }
          if(this.parent().interactMode() == 'edit'){
            str+="ID:"+ tag_str
          }


        }
        str+='</td>'
        str+='</tr>'
        return str;
      },
      _getClassName: function(name) {
        var out;
        switch(name) {
          case "uBio":
            out = "ubio";
            break;
          case "NCBI":
            out = "ncbi";
            break;
          case "Tree Base":
            out = "treeBase";
            break;
          default:
            out = "";
        }
        return out;
      },

      _getExternalLink: function(name) {
        switch(name)
        {
          case "JSTOR":
            return "http://plants.jstor.org/search?searchText=#{taxon_name_string}".interpolate({
              taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
            })
            break;
          case "GBIF":
            return "http://data.gbif.org/search/#{taxon_name_string}".interpolate({
              taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
            })
            break;

          case "Tropicos":
            return "http://tropicos.org/NameSearch.aspx?name=#{taxon_name_string}".interpolate({
              taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
            })
            break;

          case "EOL":
            return "http://www.eol.org/search?q=#{taxon_name_string}".interpolate({
              taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
            })
            break;

          case "IPNI":
            return "http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#{taxon_name_string}&output_format=normal&query_type=by_query&back_page=query_ipni.html".interpolate({
              taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
            })
            break;

          case "uBio":
            if(this.parent().interactMode() == 'browse'){
              if (this.taxon().attributes().ubio_id){
                return "http://www.ubio.org/browser/details.php?namebankID="+this.taxon().attributes().ubio_id;
              }
              else {
                return "http://www.ubio.org/browser/search.php?search_all=#{taxon_name_string}".interpolate({
                  taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
                })
              }
            }else{
              return ""
            }


            break;

          case "NCBI":
            if(this.parent().interactMode() == 'browse'){
              if (this.taxon().attributes().ncbi_id){
                return "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id="+this.taxon().attributes().ncbi_id;
              }else {
                return "http://www.ncbi.nlm.nih.gov/taxonomy?term=#{taxon_name_string}".interpolate({
                  taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
                })
              }
            }else{
              return ""
            }

            break;

          case "Tree Base":
            if (this.taxon().attributes().treebase_id){
              return 'http://treebase.nescent.org/treebase-web/search/taxonSearch.html?query=tb.identifier.tree='+this.taxon().attributes().treebase_id.gsub("TB2:","")
            }
            else {
              return "http://treebase.nescent.org/treebase-web/search/taxonSearch.html?term=#{taxon_name_string}".interpolate({
                taxon_name_string: this.taxon().attributes().name.split(' ').join('+')
              })
            }
        }
      },


      _inARow: function(element) {
        var elem
        return (
          ( (elem = element.upper('tr')) &&
            (elem = elem.up('.widget')) &&
            (elem.readAttribute('id') == this.id())
          ) ? true : false
        )
      },

      _textFieldOrText: function(fieldName, value, size, options)
      {
        if(!value || value == 'null') {
          value = ''
          }
        options = options || { }
        value = String(value);
        var styleOption;
        switch(this.parent().interactMode().toString())
        {
          case 'browse':
            if(!value || value.strip() == '')
            {
              value = "<span class='empty'>None</span>";
            }
            else
            {
              if(options['link_id'])
              {
                value = "<span class='link' data-taxon-id='" + options['link_id'] + "'>" + value + "</span>";
              }
            }
            return value;
          case 'edit':
            if(!value || value.strip() == '' || value == "null")
            {
              value = "";
            }
            return "<input type='text' size='#{size}' name='taxon[#{fieldName}]' value='#{value}' />".interpolate({
              size: size,
              fieldName: fieldName,
              value: value,
              styleOption: styleOption
            });
        }
      }
    }
  })
});
