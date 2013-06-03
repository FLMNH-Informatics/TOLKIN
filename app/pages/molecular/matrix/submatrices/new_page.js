//= require <page>
//= require <html_loader>

JooseModule('Molecular.Matrix.Submatrices', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Molecular Matrix Submatrix: New'},
      width:          { is: 'ro', init: function(){
        if (this.context().params().extraParams == "?no_seqs=true"){
          return 600
        }else{
          return 340
        }
      }},
      height:         { is: 'ro', init: function(){
        if (this.context().params().extraParams == "?no_seqs=true"){
          return 600
        }else{
          return 100
        }
      }},
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Create' },
      htmlLoader: { is: 'ro', init: function (){ return $HtmlLoader({
        pathname: 'new_project_molecular_matrix_submatrix_path'
      }, this)}},
      canRender: {is: 'ro', init: true }
    },
    methods: {
      onClick: function (event){
        var me = this;

        Event.delegate({
          '.check_all': function (event) {
            var checked = (event.element().innerHTML == "Check all");
            event.element().up('ul').select('input').each(function(chk){chk.checked = checked});
            event.element().update(checked ? "Check none" : "Check all");
          },

          '.min_check':function(event){
            var minNum = event.element().next('input').value;
            if (minNum != ""){
              var numMinimum = parseInt(minNum);
              if (!isNaN(numMinimum)){
                var els = event.element().up('ul').next().select('input[data-cellscount]').findAll(function(el){
                  var cellCount = parseInt(el.dataset.cellscount);
                  return (cellCount >= numMinimum);
                })
                event.element().up('ul').next().select('input[data-cellscount]').each(function(chk){chk.checked = false});
                els.each(function(chk){chk.checked = true});
              }else{me.notifier().warn("You must enter a number")}
            }
          },

          'input:checkbox': function (event){
            me.shiftCheck(event);
          },

          'input[type="button"][value="Create"]': function (event) {
            var form = $('new_molecular_matrix_submatrix')
              , otuChecks = $$('.submatrix_children').empty() ? $$('.chk_otu.selecting_checkbox:checked') : $$('.sub_otu_checkbox:checked')
              , markerChecks = $$('.submatrix_children').empty() ? $$('.chk_marker.selecting_checkbox:checked') : $$('.sub_marker_checkbox:checked')
              , otuIds = otuChecks.map(function(chk){ return chk.dataset.otuId })
              , markerIds = markerChecks.map(function(chk){ return chk.dataset.markerId })
              , motuIds = otuChecks.map(function(chk){ return chk.dataset.motuId })
              , matrixMarkerIds = markerChecks.map(function(chk){ return chk.dataset.matrixMarkerId })
              , requestParams = Object.extend({
                "otu_ids[]": otuIds,
                "marker_ids[]": markerIds,
                "motu_ids[]": motuIds,
                "matrix_marker_ids[]": matrixMarkerIds
              }, form.serialize({hash:true}));

            if (!markerIds.empty() && !otuIds.empty() && $('molecular_matrix_submatrix_name').value != ""){
              me.notifier().working('Creating submatrix');
              event.element().disable();
              new Ajax.Request(me.context().routes().pathFor('project_molecular_matrix_submatrices_path'),{
                requestHeaders: ["Accept", "text/html,application/json"],
                method: 'post',
                parameters: requestParams,
                onSuccess: function (response) {
                  if (response.responseText && !response.responseText.startsWith("{")){
                    $(me._parentPage()._widgets.get('userPanel')._widgets.get('submatrixViews')._id).update(response.responseText).previous().remove();
                    me.notifier().success('Submatrix created.')
                    me.frame().close();
                  }
                  if (response.responseJSON){
                    if ( response.responseJSON.empty){
                      me.notifier().warning('You must choose at least one OTU and one marker.');
                    }else if (response.responseJSON.error){
                      me.notifier().warning(response.responseJSON.error.toString());
                    }else{
                      me.notifier().success('Submatrix created.');
                      me.frame().close();
                    }
                  }
                },
                onFailure:  function (){me.notifier().error('Something went wrong.')},
                onComplete: function (){event.element().enable()}
              })
            }else{
              me.notifier().warn('You must input a name and choose at least one marker and one OTU for a submatrix.')
            }
          }
        }).call(this,event)
      }
    }
  })
})