//= require <page>
//= require <html_loader>
//= require <molecular/matrices/submatrix>

JooseModule('Molecular.Matrix.Submatrices', function () {
  JooseClass('EditPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Molecular Matrix Submatrix: Edit'},
      width:          { is: 'ro', init: 640 },
      height:         { is: 'ro', init: 600 },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Update' },
      htmlLoader: { is: 'ro', init: function (){ return $HtmlLoader({
        pathname: 'edit_project_molecular_matrix_submatrix_path'
      }, this)}},
      records: { is: 'ro', lazy: true, init: function () {
        return $Records({
          submatrix: new Molecular.Matrices.Submatrix({ id: this.context().params().id, context: this.context() })
        }, this)
      } },
      canRender:       {is: 'ro', init: true },
      otusToRemove:    {is: 'rw', init: [] },
      markersToRemove: {is: 'rw', init: [] }
    },
    after: {
      initialize: function (){
        //necessary in this situation because after pageLoad onSuccess these would remain the same
        this.setOtusToRemove([]);
        this.setMarkersToRemove([]);
      }
    },
    methods: {
      clearAdded: function (type) {

      },

      onClick: function (event){
        var me = this;

        Event.delegate({
          ".add_more": function (event){
            var add = event.element().innerHTML == "add more";
            event.element().up().next().toggle().next().toggle();
            event.element().update(add ? "cancel" : "add more")
            if (add){ }
          },

          '.check_all': function (event) {
            var checked = (event.element().innerHTML == "Check all");
            event.element().up('ul').select('input').each(function(chk){chk.checked = checked});
            event.element().update(checked ? "Check none" : "Check all");
          },

          'input:checkbox': function (event){
            me.shiftCheck(event);
          },

          ".remove": function (event) {
            var newText = (event.element().innerHTML == "remove") ? "keep" : "remove"
              , childType = event.element().dataset.submatrixChildType
              , childId = event.element().dataset.submatrixChildId
              , otusRemove = this._otusToRemove
              , markersRemove = this._markersToRemove;
            event.element().up('li').toggleClassName('removed');
            event.element().update(newText);
            if (childType == "otu"){
              if (this._otusToRemove.indexOf(childId) == -1){
                otusRemove.push(childId)
                this.setOtusToRemove(otusRemove)
              }else{
                this.setOtusToRemove(otusRemove.without(childId))
              }
            }else if (childType == "marker"){
              if (this._markersToRemove.indexOf(childId) == -1){
                markersRemove.push(childId)
                this.setMarkersToRemove(markersRemove)
              }else{
                this.setMarkersToRemove(markersRemove.without(childId))
              }
            }
          },

          'input[type="button"][value="Update"]': function (event){
            var updateParams = Object.extend({
              "otus_to_remove[]": this._otusToRemove,
              "markers_to_remove[]": this._markersToRemove,
              name: $("submatrix_name").value
            }, $('add_form').serialize({hash: true}));

            me.notifier().working('Updating submatrix...');
            new Ajax.Request(me.context().routes().pathFor('project_molecular_matrix_submatrix_path'),{
              method: "put",
              requestHeaders: ["Accept", "text/html,application/json"],
              parameters: updateParams,
              onSuccess: function (response){
                if (response.responseText && !response.responseText.startsWith("{")){
                  me.notifier().success('Submatrix updated.');
                  if (me._parentPage().meta._name == "Molecular.Matrix.Submatrices.ShowPage"){
                    window.location.reload(true);
                  }else{
                    $(me._parentPage()._widgets.get('userPanel')._widgets.get('submatrixViews')._id).update(response.responseText).previous().remove();
                    me.frame().loadPage('edit_project_molecular_matrix_submatrix_path', {id: me.record('submatrix')._id, matrix_id: params["matrix_id"]});
                  }
                }
                if (response.responseJSON){
                  if (response.responseJSON.error){
                    me.notifier().error(response.responseJSON.error.toString());
                  }
                }
              },
              onFailure: function (response){
                me.notifier().error('Something went wrong.');
              }
            })
          }
        }).call(this,event)
      }
    }
  })
})