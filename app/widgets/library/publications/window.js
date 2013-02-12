//= require <widgets/templates/window>
//= require <library/publication>
//= require <forms_helper>
//= require <lowpro>


Module('Widgets.Collections', function () {
  JooseClass('Window', {
    isa: Widgets.Templates.Window,
    does: FormsHelper,
    has: {
      context     : { is: 'ro', required: true, nullable: false },
      //pageFactory : { is: 'ro', init: function () { return new TOLKIN.PageFactory( { frame: this }) } },
      title       : { is: 'ro', init: 'Publication Details Window' },
      collection  : { is: 'ro', required: true, nullable: false },
      width       : { is: 'ro', init: 775 }
     
    }
    ,
    after: {
      initialize: function () {
        //params['collection_id'] = this.collection().id();
       // params['id'] = this.collection().id();
        this.context().interactMode().addObserver(this, this.render)
        
      }
    },
    override: {
      render: function() {
        var attrs = this.collection().attributes();
        var evaluated =
        this.parent().templates().get('library/publications/show').evaluate({
          
          id_qualifier                                    : this._textFieldOrText('name', attrs.identification_qualifier),
          "text_field_or_text('name')"                    : this._textFieldOrText('name', this.collection().attributes().name, { size: 5 }),
          "text_field_or_text('code')"                    : this._textFieldOrText('code', this.collection().attributes().code, { size: 5 }),
          "text_field_or_text('publisher')"               : this._textFieldOrText('publisher', this.collection().attributes().publisher, { size: 5 }),
          save_button                                     : (this.parent().interactMode() == 'edit' ) ? 'display: block' : 'display: none',
          form_action                                     : this.context().routes().pathFor('project_collection_path',{ id: this.collection().id()})

        });
        this.SUPER({ yield: evaluated });
        if(this.context().interactMode() == 'edit') { this.postRender() } // DONT COMMENT THIS OUT - see me - ChrisG

        return this;
      }
    },
    methods: {

      _textFieldOrText: function(fieldName, value, options) {
        if(fieldName=="longitude" || fieldName=="latitude")
            value=this._truncateTo6(value);

        options = options || { }
        switch(this.parent().interactMode().toString()) {
          case 'browse':
            if(!value || value.toString().strip() == '') {
              value = "<span class='empty'>None</span>";
            } else {
              if(options['link_id']) {
                value = "<span class='link' data-collection-id='" + options['link_id'] + "'>" + value + "</span>";
              }
            }
            return value

          case 'edit'  :
            return "<input type='text' name='collection[#{fieldName}]' value='#{value}' size='#{size}'/>".interpolate({
              fieldName: fieldName,
              value: value,
              size: options.size || 10
            });
            return value
        }
      }

     
    }
  })
});
