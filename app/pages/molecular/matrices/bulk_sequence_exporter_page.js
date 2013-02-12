//= require <page>
//= require <widgets/molecular/matrices/user_panel>
//= require <molecular/sequences/sequence_exporting>


Module('Molecular.Matrices', function () {
  JooseClass('BulkSequenceExporterPage', {
    isa:  Page,
    does: SequenceExporting,
    has: {
      canRender: { is: 'ro', init: false }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        if (event.element().match('a')){
          var tool = event.element().innerHTML;
          if (event.element().innerHTML == "Export FASTA file" || event.element().innerHTML == "Create Alignment"){
            me.notifier().working('Processing selections...')
            var selector  = 'input[type="checkbox"]:checked'
              , type      = $('export_union').checked ? 'export_union' : 'export_intersection'
              , otu_ids   = []
              , marker_ids= [];
            $('matrix_otus_table').select(selector).each( function (chk){ otu_ids.push(chk.readAttribute('data-otu-id')) } );
            $('matrix_markers_table').select(selector).each( function (chk) { marker_ids.push( chk.readAttribute('data-marker-id') ) } );
            var url = '/projects/' + params['project_id'] + '/molecular/sequences/seq_ids_from_markers_and_otus?export_type=' + type + '&otu_ids=' + otu_ids.join(',') + '&marker_ids=' + marker_ids.join(',') + '&matrix_id=' + params['id']
            new Ajax.Request(me.context().routes().pathFor('seq_ids_from_markers_and_otus_project_molecular_sequences_path'), {
              method: 'post',
              parameters: {
                "export_type": type,
                "otu_ids":     otu_ids.join(','),
                "marker_ids":  marker_ids.join(','),
                "matrix_id":   params["id"]
              },
              onSuccess: function (response) {
                if (response.responseJSON.seq_ids) {
                  var idCount = response.responseJSON.seq_ids.length;
                  if (idCount > 50){
                    if (confirm("You have selected " + response.responseJSON.seq_ids.length.to_s + " sequences.  This may take very long time, do you wish to continue?")){
                      me.useTools(tool, response.responseJSON.seq_ids)
                    }
                  }else{me.useTools(tool,response.responseJSON.seq_ids)}
                }else if (response.responseJSON.msg){
                  me.notifier().error(response.responseJSON.msg)
                }else{
                  me.notifier().error('Something went wrong')
                }
              },
              onFailure: function (response) {me.notifier().error('Something went wrong')}
            })
          }
        }
        Event.delegate({
          '#edit_matrix': function(event){this.frame().viewport().widget('window').loadPage('edit_project_molecular_matrix_path')},
          'input:checkbox': function (event) { this.shiftCheck(event);}
        }).call(this,event)
      },
      useTools: function(tool, ids){
        switch(tool){
          case "Export FASTA file":  this.exportSelectedSeqs({seq_ids: ids});     break;
          case "Create Alignment":   this.createAlignment({ids: ids});        break;
        }
      }
    }
  })
})