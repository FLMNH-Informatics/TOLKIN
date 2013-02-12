//= require <page>
//= require <html_loader>
//= require <chromosome/probes/probe_catalog>

JooseModule('Chromosome.ZFiles', function () {
  JooseClass('ShowAddProbePage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      width:     { is: 'ro', init: 740 },
      height:    { is: 'ro', init: 415 },
      title:     { is: 'ro', init: 'Assign Probe to ZVI File'},
      savable:   { is: 'ro', init: true},
      saveButtonText: { is: 'ro', init: 'Attach Probe(s)' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_probe_project_chromosome_z_file_path'
      }, this)}},
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog: new Chromosome.Probes.ProbeCatalog({
          parent: this.frame(),
          collection: Chromosome.Probe.collection({context: this.context()}),
          canPublify: false
        })
      }, this )}},
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'
      ], this )  } }
    },
    methods: {
      attachProbe: function (probeIds, fn){
        var me  = this
          , dye = {
              id:        $('hybridization_dye_id').value,
              dye_value: $('hybridization_dye_id').down("option[value='" + $('hybridization_dye_id').value + "']").innerHTML
            };
        fn = fn || function(){};
        if (dye.id != ''){
          if (me.interactMode()._value == 'edit'){
            var conf = probeIds.split(',').length > 1 ? confirm('Are you sure you want to use dye "' + dye.dye_value + '" for each selected probe?') : true;
            me.notifier().working('Assigning probe(s) to ZVI file...');
            if (conf){
              if (probeIds.split(',').length > 0){
                new Ajax.Request(window.location.pathname + '/create_hybridization', {
                  method: 'put',
                  parameters: {
                    "dyeId": dye.id,
                    "probeIds[]": probeIds.split(',')
                  },
                  requestHeaders: ['Accept', 'application/json'],
                  onSuccess: function(transport){
                    $('probes_list').replace(transport.responseJSON.html);
                    me.notifier().success('Probe(s) successfully assigned to ZVI file.');
                    fn();
                  },
                  onFailure: function(){me.notifier().error("Something went wrong.  We have been notified.")}
                });
              }else{me.notifier().warn('You must choose a probe.')}
            }
          }
        }else{me.notifier().warn('You must select a dye.')}
      },
      addDye: function (dyeValue){
        var me = this;
        $('add_dye').disable();
        me.notifier().working('Creating dye...')
        new Ajax.Request('/projects/' + params["project_id"] + "/chromosome/dyes/", {
          method: "post",
          parameters: {"dye_value": dyeValue},
          onSuccess: function(transport){
            var newDye = transport.responseJSON.dye;
            $('hybridization_dye_id').insert({bottom: new Element('option', {value: newDye.id}).update(newDye.dye_value)})
            $('hybridization_dye_id').selectedIndex = ($('hybridization_dye_id').length - 1)
            me.notifier().success('Dye created.')
            me.toggleNewDye();
          },
          onFailure:  function(){ me.notifier().error('Something went wrong.'); },
          onComplete: function(){ $('add_dye').enable(); }
        });
      },
      toggleNewDye: function(){
        $('add_dye_control').toggle();
        $('add_new_dye').innerHTML = $('add_new_dye').innerHTML == 'add new dye' ? 'cancel' : 'add new dye';
      },
      onClick: function (event){
        var me = this;
        if (event.element() == $$('input.button.active.saveButton[value="Attach Probe(s)"]')[0]){
          me.attachProbe(me.widgets().get('catalog').selected()._ids.toString(), function(){
            me.frame().close();
          });
        }else if (event.element() == $('add_new_dye')){
          me.toggleNewDye();
        }else if (event.element() == $('add_dye')){
          if ($('dye_dye_value').value != ''){
            var existingLowerCase = $('hybridization_dye_id').select('option').collect(function(opt){return opt.innerHTML.toLowerCase();})
              , newDye = $('dye_dye_value').value;
            if (existingLowerCase.indexOf(newDye.toLowerCase()) == -1){
              me.addDye(newDye);
            }else{ me.notifier().warn('That dye already exists') }
          }else{me.notifier().warn('You must type a dye value to add a new dye.')}
        }
      }
    }
  })
})