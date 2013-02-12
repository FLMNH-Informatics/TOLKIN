JooseRole('FormsHelper', {
  methods: {
    _dateField: function (record, attribute) {
      var splitDate = {};
      if(record.attributes()[attribute]) {
        var dateMatch = record.attributes()[attribute].match(/(\d{4})\-(\d{2})\-(\d{2})/)
        splitDate = { Y: dateMatch[1], mm: dateMatch[2], dd: dateMatch[3] }
      }
      switch(this.context().interactMode().toString()) {
        case 'browse':
          return [ splitDate['Y'], splitDate['mm'], splitDate['dd'] ].compact().join(' / ');
        case 'edit':
          var objectName = record.meta.className().split('.').pop().underscore();
          return this.context().templates().get('forms/_date_field').evaluate({
            object_name: objectName,
            attribute_name: attribute,
            date: splitDate
          });
      }
    },
    dateFieldInit: function (attrName) {
      var formElements = {};
      formElements[''+attrName+'_Y'] = 'Y';
      formElements[''+attrName+'_mm'] = 'm';
      formElements[''+attrName+'_dd'] = 'd';

      datePickerController.createDatePicker({
        formElements: formElements,
        showWeeks:    true,
        statusFormat: "l-cc-sp-d-sp-F-sp-Y",
        positioned:   ''+attrName+'_button_wrapper'
      });
    }
  }
});