//= require <widget>
//= require <molecular/insd/seqs/action_list>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    has: {
      catalog: { is: 'rw' },
      widgets: { is: 'ro', init: function () { return $Reg({
        actionList: new Molecular.Insd.Seqs.ActionList({parent: this})
      }, this)}}
    },
    methods: {
      setCatalog: function (catalog) {
        this._catalog = catalog;
        this.widgets().get('actionList').setCatalog(catalog);
      }
    }
  })
});


