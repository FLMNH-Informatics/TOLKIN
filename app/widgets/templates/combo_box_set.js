//= require <widget>

JooseModule('Widgets.Templates', function () {
  JooseClass('ComboBoxSet', {
    isa: Widget,
    has: {
      modelObject:   { is: 'ro', required: true, nullable: false },
      comboBoxClass: { is: 'ro', required: true, nullable: false },
      attributeName: { is: 'ro', required: true, nullable: false },
      context:       { is: 'ro', required: true, nullable: false },
      widgets:    { is: 'ro', init: function () { return $Reg({
            comboBoxes: this._initComboBoxesFromView()
      }, this) }}
    },
    methods: {
      comboBoxClass: function () { // handle conversion from string to active object
        return this._comboBoxClass.split('.').inject(top, function (obj, name) {
          return obj[name]
        })
      },

      comboBoxes: function () {
        if(!this.widgets().get('comboBoxes')) {
          this.widgets().add($H({ comboBoxes: this._initComboBoxesFromRecord() }));
        }
        return this.widgets().get('comboBoxes');
      },

      _initComboBoxesFromView: function () {
        var comboBoxes = $$('#'+this.id()+' .combo_box').inject([], function (arr, comboElement) { // if combo boxes are visible in view currently, initialize from that
          var comboBox = new (this.comboBoxClass())({
            parent: this,
            object: this.modelObject(),
            idNumber: parseInt(comboElement.id.match(/^.+_(\d+)$/)[1])
          });
          return(arr.push(comboBox) && arr);
        }, this);
        return(comboBoxes.empty() ? null : comboBoxes);
      },
      
      _initComboBoxesFromRecord: function () {
        var index, out, attribValues;
        index = 0; out = [];
        attribValues = this.modelObject().attributes()[this.attributeName()];
        while(index < (attribValues.size() + 1)) {
          out.push(new (this.comboBoxClass())({
            parent: this,
            object: this.modelObject(),
            idNumber: index
          }))
          index++;
        }
        return out;
      },

      render: function () {
        $(this.id()).replace(this.renderToString());
      },

      renderToString: function () {
        return(
          "<div id='"+this.id()+"' class='widget'>"+
          this.comboBoxes().compact().inject('', function (out, comboBox) {
            return out+this._comboBoxRow(comboBox)
          }, this)+
          "</div>"
        )
      },

      _comboBoxRow: function (comboBox) {
        return(
          (comboBox.value() || comboBox.idNumber() == 0 || this.context().interactMode() == 'edit') ? // dont show empty rows in browse mode beyond first row
            "<table class='combo_box_row'><tr>"+
              "<td>"+comboBox.renderToString()+"</td>"+
              ((this.context().interactMode() == 'browse' || comboBox.idNumber() == 0) ?
                '' : "<td class='remove_button'>X</td>"
              )+
            "</tr></table>" :
            ""
        )
      },

      onChange: function () {
        if(!$(this.id()).down("input[value='']")) {
          this.comboBoxes().push(new (this.comboBoxClass())({
            parent: this,
            object: this.modelObject(),
            idNumber: this.comboBoxes().size()
          }));
          this.widgets().add(this.comboBoxes().last())
          this.render();
        }
      },
      onClick: function (event) {
        Event.delegate({
          '.remove_button': function () {
            var row = event.element().up('.combo_box_row');
            var widgetElement = row.down('.combo_box');
            var index = parseInt(widgetElement.id.match(/.+_(\d+)/)[1]);
            var comboBox = this.comboBoxes()[index];
            comboBox.destroy();
            delete this.comboBoxes()[index];
            row.remove();

          }
        }).bind(this)(event)
      }
    }
  })
});
