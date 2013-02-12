//= require <page>
//= require <widgets/otu_groups/user_panel>
//= require <otu_group>

JooseModule('OtuGroups', function (){
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      savable: { is: 'ro', init: true},
      title: { is: 'ro', init: 'OTU Group : Show'},
      width: { is: 'ro', init: 450 },
      height: { is: 'ro', init: 400 },
      createCopy: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        userPanel: new OtuGroups.UserPanel({ parent: this.frame().viewport(), context: this.context() })
      }, this)}},
      records: { is: 'ro', lazy: true, init: function () {
          return ($Records({
            otuGroup: new OtuGroup({ context: this.frame().context(), id: this.context().params().id })
          }, this))}}
    },
    methods:{
      onClick: function(event){
        var me = this;
        Event.delegate({
          '.add_otu_to_group': function (event) {
            me.context().viewport().widget('window').loadPage('show_add_otu_project_otu_group_path');
          },
          '.move': function (event) {
              event.stop();
              var anchor   = event.element().nodeName == "IMG" ? event.element().up('a') : event.element()
                , moveType = anchor.dataset.move.toString()
                , otuId    = anchor.up('tr').dataset.otuId.toString()
                , otuName  = anchor.up('tr').dataset.otuName.toString()
                , conftext = "Are you sure you want to " + (moveType == "remove_from_list" ? "remove " : "move " ) + otuName + "?"
                , notification = moveType == "remove_from_list" ? "Removing OTU..." : "Moving OTU..."
                , success = moveType == "remove_from_list" ? "OTU removed successfully." : "OTU moved successfully."
                , movePath = '/projects/' + params['project_id'] + '/otu_groups/' + params['id'] +'/change_position?otu_id=' + otuId + '&move=' + moveType;
              anchor.up('tr').setStyle({backgroundColor: 'pink'});
              if (confirm(conftext)){
                me.context().notifier().working(notification);
                new Ajax.Request(movePath, {
                  requestHeaders: ["Accept", "application/json"],
                  onSuccess: function (transport) {
                    if (transport.responseJSON.msg == 'ok'){
                      if (transport.responseJSON.partial) $('otus_list').replace(transport.responseJSON.partial)
                      me.context().notifier().success(success);
                    }else{
                      me.context().notifier().error(transport.responseJSON.msg.toString());
                    }
                  },
                  onFailure: function () {me.context().notifier().error('Something went wrong.')}
                } )
              }else{
                anchor.up('tr').writeAttribute("style","");
              }
            }
        }).call(this, event)
      }

    }

  })
})

