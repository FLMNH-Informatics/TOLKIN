//= require <widget>
//= require <matrices/changeset>
//= require <matrices/changesets/change>

JooseModule('Matrices', function() {
  JooseClass('VersioningPane', {
    isa: Widget,
    has: {
      changeset: { is: 'ro', init: function () { return(
          new Matrices.Changeset({
            id: $(this.id()).readAttribute('data-changeset-id'),
            context: this.context()
          })
      )}},
      changes:   { is: 'ro', init: function () { 
//           var Change = Matrices.Changesets.Change;
          return(
            Matrices.Changesets.Change
              .collection({ context: this.context() })
              .where(SyncRecord.attribute("changeset_id").eq(this.changeset().id()))
              .order('position DESC')
              .limit(3)
//               .load()
          )
      }}
    },
    after: {
      initialize: function () {
        this.changeset().addObserver(this, this._updateChangesList);
        Matrices.Changesets.Change.addObserver(this, this._onDataChange);
      }
    },
    methods: {
      destroy: function() {
        Matrices.Changesets.Change.deleteObserver(this);
        //this.session().widgets().unregister(this);
      },

      onClick: function(e) {
        Event.delegate({
          '#revert_all_changes_link': function(e) {
            this.changeset().revertAll(this._changeset.id);

          },
          '.revert_change_link' : function(e) {
            new Matrices.Changesets.Change({ context: this.context(), id: e.element().up('li').getAttribute('data-change-id')}).revert();
          }
        }).bind(this)(e);
      },

      update: function() {
        alert('hello');
      },

      _changeItemRows: function() {
        var out = "";
        this.changes().data().each(function(change) {
          out += "<li data-change-id='" + change.id + "'>" + Matrices.Changesets.Change.toString(change) + " <a class='revert_change_link'>revert</a></li>";
        });
        return out;
      },

      _changesStartPosition: function() {
        if(this.changes().size() == 0) {
          return 1;
        } else if(this.changes().size() < 3) {
          return this.changes().data().first().position;
        } else {
          return this.changes().data().last().position - 2;
        }
      },

      _onDataChange: function(eventName, id) {
        switch(eventName) {
          case 'update':
            if(!id) {
              this._changeset.loadAttributes({
                callback: this._updateChangesList.bind(this)
              });
            } else {
              this._updateChangesList();
            }
        }

      },

      _updateChangesList: function() {
        var evaluatedPartial = this.parent().templates().get('shared/panes/_versioning_pane_changes_list').evaluate({
          changes_start_position: this._changesStartPosition(),
          change_item_rows: this._changeItemRows()
        });
        $('changes_list').replace(evaluatedPartial);
      }
    }
  })
});

