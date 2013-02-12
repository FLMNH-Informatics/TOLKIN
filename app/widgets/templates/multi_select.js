//= require <widget>

Module('Widgets.Templates', function () {
  JooseClass('MultiSelect', {
    isa: Widget,
    has: {
      object:    { is: 'ro', required: true, nullable: false },
      method:    { is: 'ro', required: true, nullable: false },
      dataClass: { is: 'ro', required: true, nullable: false }
    },
    after: {
      initialize: function () {
        this.dataClass().addObserver(this, this._onDataChange)
      }
    },
    methods: {
      destroy: function() {
        this.dataClass().deleteObserver(this);
      },

      toHTML: function() {
        var out =  "<select id='#{id}' multiple='multiple'>".interpolate({
          id: this.id
        });
        if(this.object().attributes()[this.method()].size() > 0) {
          this.object().attributes()[this.method()].each(function(sequence) {
            out += "<option value='#{sequence_id}'>#{sequence_accession}#{primary}</option>".interpolate({
              sequence_id: sequence.id,
              sequence_accession: sequence.locus,
              primary: sequence.id == this.object().attributes()['primary_sequence_id'] ? ' (primary)' : ''
            });
          }, this);
        } else {
          out += "<option>No items</option>";
        }

        out += "</select>";
        return out;
      },

      _element: function() {
        return $(this.id);
      },

      _onDataChange: function(changeType, itemId) {
        if(changeType == 'destroy') {
          this._element().down("option[value='" + itemId + "']").remove();
          if(!this._element().down('option')) {
            this._element().update('<option>No items</option>');
          }
        }
      }
    }
  })
});
