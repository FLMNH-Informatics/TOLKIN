//= require <widget>

JooseModule('Molecular.Matrices', function () {
  JooseClass('SubmatrixViews', {
    isa: Widget,
    has:   {
      context: { is: 'ro', required: true, nullable: false }
    },
    methods: {
      _matrixInfo: function (){ return this.context().frame().page().matrixInfo(); },
      _datagrid:   function (){ return this.context().frame().page().widgets().get('datagrid'); },

      onClick: function (event){
        var me = this;

        Event.delegate({
          ".edit_submatrix": function (event){
            this._matrixInfo().doIfEditMode(function () {
              var submatrixId = event.element().dataset.submatrixId
                , wndw = me._parent._parent.widgets().get('window');
              wndw.loadPage('edit_project_molecular_matrix_submatrix_path', {id: submatrixId, matrix_id: params["matrix_id"]});
            }, me)
          },

          ".delete_submatrix": function (event){
            this._matrixInfo().doIfEditMode(function () {
              var name = event.element().up('li').dataset.submatrixName;
              if (confirm('Are you sure you want to delete the submatrix: "' + name + '"?')){
                me.notifier().working('Deleting submatrix "' + name + '".')
                new Ajax.Request(me.context().routes().pathFor('project_molecular_matrix_submatrix_path', {id: event.element().dataset.submatrixId}),{
                  method: "delete",
                  onSuccess: function (response){
                    me.notifier().success('Submatrix "' + name + '" deleted.');
                    event.element().up('li').remove();
                  },
                  onFailure: function (response){
                    me.notifier().error('Something went wrong.');
                  }
                })
              }
            }, me)
          },

          ".new_submatrix": function (event){
            this._matrixInfo().doIfEditMode(function (){
              me._parent._parent.widgets().get('window').loadPage('new_project_molecular_matrix_submatrix_path', {"matrix_id": params["matrix_id"], extraParams: "?no_seqs=true"});
            },this)
          },

          '#Enter_submatrix_mode': function (event){
            this._datagrid().toggleSubmatrixMode();
          }
        }).call(this,event)
      }
    }
  })
})