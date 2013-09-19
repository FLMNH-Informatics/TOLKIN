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
        var me = this;
        Event.delegate({
          'tr': function(event) {
            var el = event.element();
            if(el.getAttribute('type')!="text" && el.up('tr').dataset.link && el.up('tr').dataset.link != "" && el.nodeName != 'A') {
              window.open(el.up('tr').dataset.link,"_blank");
            }
          },
          '.search_outlink': function(event){
            var type = event.element().dataset.outlink_type;
            me.frame().notifier().working('Searching...')
            me.frame().loadPage('search_outlinks_project_taxon_path', {id: me._taxon._id, extraParams: '?outlink_type='+type })
          },
          '.tolkin_jstor_widget': function (event){
            me.frame().loadPage('show_jstor_widget_project_taxon_path',{id: me._taxon._id});
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
        str+=this._generateRow("TreeBASE", "","treebase_logo.png");
        str+=this._generateRow("NCBI", "National Center for Biotechnology Information","NCBI_logo.png");
        str+=this._generateRow("uBio", "Indexing & Organizing Biological Names","uBio_logo.gif");
        str+=this._generateRow("GBIF", "Global Biodiversity Information Facility","GBIF_logo.jpg");
        str+=this._generateRow("EOL", "Encyclopedia Of Life","EOL_logo.jpg");
        str+=this._generateRow("JSTOR", "JSTOR Plant Science","jstor_logo.gif");
        str+=this._generateRow("IPNI", "International Plant Names Index","IPNI_logo.gif");
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

        if (name == "TreeBASE"){
          str += this._treebaseLinks();
        }else if (name == "GBIF" && this.taxon().attributes()['gbif_id']){
            str += this._gbifLinks();
        }else if (name == "JSTOR"){
          str += description; //this._jstorLinks();
        }else{
          str+= description;
        }

        str+='</td>'
        str+='<td style="padding: 10px 10px 10px 10px; vertical-align:middle">'
        if(name=="uBio"||name=="NCBI" || name=="TreeBASE" || name=="GBIF" || name=="EOL")
        {
          var tag_str = "";
          var idString = name.toLowerCase() + '_id';
          tag_str =  this._textFieldOrText(idString, this.taxon().attributes()[idString],3);
          tag_str += this._outlinkSearchButton(name);

          if(this.parent().interactMode() == 'edit'){
            str+="ID:"+ tag_str
          }
        }
        str+='</td>'
        str+='</tr>'
        return str;
      },
      _outlinkSearchButton: function(outlink_type){
        var searchElement = '<input type="button" data-outlink_type="'+outlink_type.toLowerCase()+'" class="search_outlink" value="Find ID"/>';
        if (this.taxon().attributes()[outlink_type.toLowerCase()+'_id']){
          searchElement = '<a class="search_outlink" data-outlink_type="'+outlink_type.toLowerCase()+'">edit</a>';
        }
        return searchElement;
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
          case "TreeBASE":
            out = "treeBase";
            break;
          case "GBIF":
            out = "gbif";
            break;
          case 'EOL':
            out = 'eol'
            break;
          default:
            out = "";
        }
        return out;
      },

      _getExternalLink: function(name) {
        var urlName = this.taxon().attributes().name.split(' ').join('+');
        switch(name)
        {
          case "JSTOR":
            return "http://plants.jstor.org/search?qtype=names&query=#{taxon_name_string}".interpolate({
              taxon_name_string: urlName
            })
            break;
          case "GBIF":
            if (this.taxon().attributes().gbif_id){
              return 'http://data.gbif.org/species/#{gbif_id}'.interpolate({gbif_id: this.taxon().attributes().gbif_id})
            }
            return "http://data.gbif.org/search/#{taxon_name_string}".interpolate({
              taxon_name_string: urlName
            })
            break;

          case "Tropicos":
            return "http://tropicos.org/NameSearch.aspx?name=#{taxon_name_string}".interpolate({
              taxon_name_string: urlName
            })
            break;

          case "EOL":
            if (this.taxon().attributes().eol_id){
              return "http://eol.org/pages/#{eol_id}/overview".interpolate({eol_id: this.taxon().attributes().eol_id})
            }else{
              return "http://www.eol.org/search?q=#{taxon_name_string}".interpolate({
                taxon_name_string: urlName
              })
            }
            break;

          case "IPNI":
            return "http://www.ipni.org/ipni/simplePlantNameSearch.do?find_wholeName=#{taxon_name_string}&output_format=normal&query_type=by_query&back_page=query_ipni.html".interpolate({
              taxon_name_string: urlName
            })
            break;

          case "uBio":
            return (this.taxon().attributes().ubio_id ? ("http://www.ubio.org/browser/details.php?namebankID="+this.taxon().attributes().ubio_id) :
              ('http://www.ubio.org/browser/search.php?search_all=' + urlName)
              );
            break;

          case "NCBI":
            if (this.taxon().attributes().ncbi_id){
              return "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id="+this.taxon().attributes().ncbi_id;
            }else {
              return "http://www.ncbi.nlm.nih.gov/taxonomy?term=#{taxon_name_string}".interpolate({
                taxon_name_string: urlName
              })
            }
            break;

          case "TreeBASE":
            if (this.taxon().attributes().treebase_id){
              return 'http://treebase.org/treebase-web/search/taxonSearch.html?query=tb.identifier.tree='+this.taxon().attributes().treebase_id.gsub("TB2:","")
            }
            else {
              return "http://treebase.org/treebase-web/search/taxonSearch.html?query=dcterms.title==%22#{taxon_name_string}%22".interpolate({
                taxon_name_string: urlName
              })
            }
        }
      },

      _gbifLinks: function (){
        var str = '<a href="'+this._getExternalLink('GBIF')+'" target="_blank">Default Portal</a>';
            str += ' | ';
            str += '<a href="http://uat.gbif.org/species/'+this.taxon().attributes()['gbif_id']+'" target="_blank">Beta Portal</a>';
        return str;
      },

      _jstorLinks: function (){
        var str = '<a href="'+this._getExternalLink('JSTOR')+'" target="_blank">JSTOR Plant Science </a>'
        str+= ' | '
        str+= '<a class="tolkin_jstor_widget">TOLKIN JSTOR Widget</a>'
        return str;
      },

      _treebaseLinks: function(){
        var linkTable = ""
          , treebaseUrl = "http://treebase.org/treebase-web/search/taxonSearch.html?query=tb.identifier.taxon=Tx#{treebase_id}&format=#{format}&recordSchema=#{recordSchema}";

        if (this.taxon().attributes().treebase_id){
          var treebase_id = this.taxon().attributes().treebase_id;

          linkTable += '<table id="treebase_links">' +
              '<tr>' +
                '<th>Trees</th>' +
                '<td style="align:center;border-top: none;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexml', recordSchema: 'tree'}) + '">NeXML</a></td>' +
                '<td style="align:center;border-top: none;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'rss1', recordSchema: 'tree'}) + '">List</a></td>' +
                '<td style="align:center;border-top: none;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexus', recordSchema: 'tree'}) + '">Nexus</a></td>' +
              '</tr>' +
              '<tr>' +
                '<th>Matrices</th>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexml', recordSchema: 'matrix'}) + '">NeXML</a></td>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'rss1', recordSchema: 'matrix'}) + '">List</a></td>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexus', recordSchema: 'matrix'}) + '">Nexus</a></td>' +
              '</tr>' +
              '<tr>' +
                '<th>Studies</th>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexml', recordSchema: 'study'}) + '">NeXML</a></td>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'rss1', recordSchema: 'study'}) + '">List</a></td>' +
                '<td style="align:center;"><a target="_blank" href="' + treebaseUrl.interpolate({treebase_id: treebase_id, format: 'nexus', recordSchema: 'study'}) + '">Nexus</a></td>' +
              '</tr>' +
            '</table>';
        }
        return linkTable;
      },

      _inARow: function(element) {
        var elem
        return (
          ( (elem = element.upper('tr')) &&
            (elem = elem.up('.widget')) &&
            (elem.readAttribute('id') == this.id()) &&
            (element.up('table').readAttribute('id') != 'treebase_links')
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
