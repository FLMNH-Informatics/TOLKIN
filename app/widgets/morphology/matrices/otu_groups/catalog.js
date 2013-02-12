//= require <templates/catalog>
//= require <morphology/matrices/otu_groups/tool_tip>
//= require <morphology/matrices/otu_groups/catalogs/action_panel>
//= require <morphology/matrices/morphology_matrices_otu_groups>
//= require <raphael/raphael>
//= require <raphael/colorpicker>


JooseModule('Morphology.Matrices.OtuGroups', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      hasFilterSet:     {is: 'ro', init: false},
      collectionName: { init: 'matrix::branch' },
      limit: { is: 'rw', init: 200, nullable: false },
      collectionClass: { init: function () { return Morphology.Matrices.MorphologyMatricesOtuGroups }},
      collection: { is: 'ro', init: function () { return(
          Morphology.Matrices.MorphologyMatricesOtuGroups.collection({ context: this.context() }))}},
      tooltip:         { is: 'ro', init: function(){
              var toltip = new Morphology.Matrices.OtuGroups.ColorPickerToolTip({ parent: this.viewport()});
              this.viewport().widgets().add(toltip );
              return toltip;
            } },
      widgets:          {is: 'ro', init: function () {return $Reg({
            actionPanel: new Morphology.Matrices.OtuGroups.Catalogs.ActionPanel({parent: this , context: this.context()}),
            filterSet:
              this.hasFilterSet() ?
                new Templates.Catalogs.FilterSet({context: this.context(), parent: this, catalog: this})
                : new Templates.Null({parent: this})
      }, this);}},
      columns: { init: function () { return [
            { attribute : "otu_group.name",   label : 'Otu Group',            width : 250 },
            { attribute : "color",       label : 'Color',     width : 100 },
            { attribute : "creator.label",    label : 'Added By', width : 150 }  ] } } },
    override: {
      onRowClick: function (event) {
            this.tooltip().move(event.pointer());
            str = '<form action="" method="post">' +
                  '<div id="colorpicker">contents</div>'+
                  '<input type="text" id="output" value="#eeeeee"/>'+
                  '<input type="submit" />'+
            '</form>';
             this.tooltip().update(str);
             this.tooltip().show();
             this.tooltip()._record = new Morphology.Matrices.MorphologyMatricesOtuGroups({context: this.context() , id: event.element().up('.sortable').readAttribute('data-id') });
            var out = document.getElementById("output");
            // this is where colorpickers created

            pos = Element.cumulativeOffset($('colorpicker'))
            //var pos = $('colorpicker').Offset();

             var cp = Raphael.colorpicker(event.pointer().x+15, event.pointer().y+15, 200, "#fff",$('colorpicker'));

            // assigning onchange event handler
            out.onkeyup = cp.onchange =  function (clr) {
                clr = this == out ? this.value : clr;
                out.value = clr;
                this != cp && cp.color(clr);
                out.style.background = clr;
                out.style.color = Raphael.rgb2hsb(clr).b < .5 ? "#fff" : "#000";
            };
            // that’s it. Too easy
       
        }
    }
  })
});