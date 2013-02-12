//= require <templates/action_panel>
//= require <molecular/insd/seq>
//= require <widget>
//= require <widgets/templates/tooltip>

Module('Molecular.Insd.Seqs.SeqCatalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      buttons: { is: 'ro', init: function () { return [
          { label: 'Add to Cell', tool: 'add_to_cell', img: { src: '/images/small_addnew.gif' }, imode: 'edit' }
      ] } },
      catalog: { is: 'ro', init: function () { return this.parent() } }
    },
    methods: {
      onClick: function(event) {
        //THERE IS NO DELETE BUTTON IN THE ACTION PANEL SO THIS ISN'T USED.  AT SOME POINT WE MIGHT WANT ONE
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Delete':
                var hasConfirmed = confirm('Are you sure you would like to delete the selected Sequence(s)?');
                if(hasConfirmed) {
                    var me = this;
                    var selectedConds = this._parent.selected().toString()
                  new Ajax.Request(
                  me.route('destroy_all_project_molecular_sequences_path'), {
                    method: 'put',
                    parameters: { conditions: selectedConds },
                    onSuccess: function () {
                      me.catalog().selected().deselectAll()
                      var seq = new Molecular.Insd.Seq({ context: me.context() })
                      seq.fire('destroy', { memo: seq });
                      me.notifier().success('Sequence(s) deleted successfully');
                    }
                  })
                }
              break
          }
        }
      }).call(this, event)
    }
   }
  })
});