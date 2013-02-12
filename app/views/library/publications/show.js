//= require <page>
//= require <library/publication>

Module('Views.Library.Publications', function () {
  JooseClass('Show', {
    isa: Page,
    has: {
      title: {is: 'ro', init: 'Show Publication'},
      width:              {is: 'ro', init: 900},
      height:             {is: 'ro', init: 500},
      records: {is: 'ro', lazy: true, init: function () {return $RSet({
          alignment:
            new Library.Publication({id: params['id'], context: this.frame().context()})
      }, this)}}
    },
    methods: {
      onLoad: function () {
        var me=this;
        new Ajax.Request('/projects/' + params['project_id'] + '/publications/'+ params['id'], {
          requestHeaders: { Accept: 'text/html' },
          method: 'get',
          onSuccess: function(transport) {
            me._contents = transport.responseText;
            //me.frame().render();
            //me.frame().refresh();
            me.state().set('loaded');
            //if(options.onSuccess) { options.onSuccess() }
          }
        });
      },
      publication: function () {return this.records().get('publication')},
      renderToString: function () {
        /*var content = this.context().templates().get('library/publications/show').evaluate({
          form_action: '/projects/' + params['project_id'] + '/publications/' + params['id'],
         // alignment: this.records().get('alignment').attributes(),
          "text_field_or_text('name')"                    : this._textFieldOrText('name', this.collection().attributes().name, { size: 5 }),
          "text_field_or_text('code')"                    : this._textFieldOrText('code', this.collection().attributes().code, { size: 5 }),
          "text_field_or_text('publisher')"               : this._textFieldOrText('publisher', this.collection().attributes().publisher, { size: 5 }),
          "save_button()"                    : this._saveButton()
        });*/
        return this._contents;
        //return this.frame().render({ yield: content, title: 'Alignment ' + params['id'] });
      },

      onSubmit: function (event) {
        event.stop();
        $(this.frame().id()).down('.status_area').update('saving ...');
        var page = this;
        event.element().request({
          onSuccess: function () {$(page.frame().id()).down('.status_area').update('saved')},
          onFailure: function (transport) {page.frame().notifier().error(transport.responseText)}
        });
      },
      onClick: function(event){
        var me = this;
        Event.delegate({
          '#fasta-view' : function (event) {
             $('fasta-view').replace('<a id="original-view" href="#">view Original</a>')
             $('align-text').innerHTML = me.alignment().attributes().seq.gsub(/[\w-]{80}/, function(match) {return match[0]+"\n"})
          },
          '#original-view' : function (event) {
             $('original-view').replace('<a id="fasta-view" href="#">view Fasta</a>')
             $('align-text').innerHTML = me.alignment().attributes().seq
          }
        })(event);
      },
      _textFieldOrText: function(fieldName, value, options) {
        options = options || { }
        switch(this.context().interactMode().toString()) {
          case 'browse':

            if(!value || (value.strip && value.strip() == '')) {
              value = "<span class='empty'>None</span>";
            } else {
              if(options['link_id']) {
                value = "<span class='link' data-collection-id='" + options['link_id'] + "'>" + value + "</span>";
              }
            }
            return value
            break;
          case 'edit'  :
            return "<input type='text' name='primer[#{fieldName}]' value='#{value}' size='#{size}'/>".interpolate({
              fieldName: fieldName,
              value: value,
              size: options.size || 10
            });
            return value
        }
      },

      _textAreaOrText: function(fieldName, value, options, rows, cols) {
        options = options || { }
        switch(this.context().interactMode().toString()) {
          case 'browse':
            if(!value || value.strip() == '') {
              value = "<span class='empty'>None</span>";
            } else {
              value = "<div style='overflow: auto; width:800px' ><pre>" + value.gsub(/[\w-]{80}/, function(match) {return match[0]+"\n"}) + "</pre></div>";
            }
            return value
            break;
          case 'edit':
            return "<textarea wrap='off' style='font-family:courier, monospace' rows='#{rows}' cols='#{cols}' name='primer[#{fieldName}]' value='#{value}' size='10'>#{value}</textarea>".interpolate({
              fieldName: fieldName,
              value: value,
              rows: rows,
              cols: cols
            });

        }
      },
      _alignment: function(fieldName, value, options, rows, cols) {
        options = options || { }
        switch(this.context().interactMode().toString()) {
          case 'browse':
            if(!value || value.strip() == '') {
              value = "<span class='empty'>None</span>";
            } else {
              value = "<div style='overflow: auto; width:800px' ><pre id='align-text'>" + value + "</pre></div>";
            }
            return value
            break;
          case 'edit':
            return "<textarea wrap='off' style='font-family:courier, monospace' rows='#{rows}' cols='#{cols}' name='primer[#{fieldName}]' value='#{value}' size='10'>#{value}</textarea>".interpolate({
              fieldName: fieldName,
              value: value,
              rows: rows,
              cols: cols
            });

        }
      },
      _formatButton: function(){
        if(this.context().interactMode() == 'browse'){
          return '<a href="#" id="fasta-view">view Fasta</a>'
        }
      },
      _saveButton: function(){
        if(this.context().interactMode() == 'edit'){
          return "<input style='margin:10px' type='submit' style='save_button_display' value='save' />"
        }
      }
    }
  })
});