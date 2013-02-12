//= require <roles/fires_events>

JooseClass('SimpleSelected', {
  does: [ Roles.FiresEvents ],
  has: {
    catalog: { is: 'ro', required: true, nullable: false },
    ids: { is: 'ro', init: function () { return new Sett() } }
  },
  methods: {

    selectId: function (id) {
      this._ids.add(id);
      this.fire('select', { memo: this });
    },
    deselectId: function (id) {
      this._ids.remove(id);
      this.fire('deselect', { memo: this });
    },
    selectAll: function () {
      $(this.catalog().id()).select('.row').each(function(item){
        this._ids.add(item.readAttribute('data-id'))
      }, this)
      this.fire('selectAll', { memo: this });
    },
    deselectAll: function () {
      this._ids.clear();
      this.fire('deselectAll', { memo: this });
    },
    size: function () {
      return this._ids.size()
    },

    conditions: function () { return this.toString() },

    serialize: function () { return this.toString(); },

    toString: function() {
      var ids = this._ids.toString()
      return (ids == '' ? 'false' : ids+'[id]')
    }
  }
})