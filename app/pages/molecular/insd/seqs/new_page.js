//= require <page>
//= require <roles/polling>
//= require <html_loader>
//= require <molecular/insd/seq>
//= require <molecular/insd/seqs/taxon_name_auto_text_field>
//= require <molecular/new_mol_marker>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      title:          { is: 'ro', init: 'Sequences : New' },
      height:         { is: 'ro', init: 500 },
      width:          { is: 'ro', init: 900 },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Save'},
      records: { is: 'ro', lazy: true, init: function () { return $Records({
        seq: new Molecular.Insd.Seq({ context: this.context() })
      }, this) } },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_molecular_sequence_path'
      }, this)}},
     widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        taxonNameField: new Molecular.Insd.Seqs.TaxonNameAutoTextField({
              object: this.record('taxon'),
              parent: this.frame()
            })
      }, this)} },
      selectControl: { is: 'rw' }
    },
    after: {
      onLoad: function () {
        var me = this;
        new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/new_sequence_marker_select', {
          method: 'get',
          requestHeaders: {Accept:'text/html'},
          onSuccess: function (response) {
            me.setSelectControl(response.responseText);
          }
        })
      }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        if (event.element().value == 'Save') {
          var markerNames = $('sequence_markers_table_body').select('input[name="seq_marker[name][]"]')
          if (markerNames.all(function (ctrl){ctrl.value != ''})){
            event.stop();
            me.notifier().working('Saving new sequence ...');
            new Ajax.Request('/projects/'+params['project_id']+'/molecular/sequences', {
              method: 'post',
              parameters: $('viewport_window_content').down('form').serialize(),
              onSuccess: function (response) {
                if (response.responseJSON){
                  var rjs = response.responseJSON;
                  if (rjs.msg){
                    me.notifier().error(rjs.msg);
                    if (rjs.msg == "You have not entered a taxa name."){
                      $('molecular_insd_seq_taxon_name_auto_input').setStyle({backgroundColor: 'red'});
                    }
                  }else if (rjs.id){
                    new Molecular.Insd.Seq({ context: me.context() }).fire('create');
                    me.notifier().success('Successfully created sequence');
                    me.frame().loadPage('project_molecular_sequence_path', { id: rjs.id });
                  }
                  else{
                    me.notifier().error("Something went wrong.  Problem creating sequence.");
                  }
                }
              },
              onFailure: function (transport) {
                var msg = transport.responseJSON.msg.toString();
                me.notifier().error(msg);
              },
              onComplete: function (response) {}
            })
          }else{
            $('sequence_markers_table_body').select('input[name="seq_marker[name][]"]').each(function(ctrl){
              if(ctrl.value == ''){
                ctrl.setStyle({backgroundColor: 'red'})
              }
            });
            me.notifier().error('You must choose a name for the marker.');
          }
        }
        else if (event.element().hasClassName('toggle_marker_control')) {
          showMarkerFields(event.element(), me);
        }
      }
    }
  })
})