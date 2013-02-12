//= require <widget>

JooseModule('OtuGroups', function () {
  JooseClass('ActionList', {
    isa: Widget,
    has: { context: {is: 'ro', required: true, nullable: false}},
    methods: {
      onClick: function(event){
        event.stop();
        var me = this;
        Event.delegate({
          '.Add_Otu_to_Group': function (event) {
            me.viewport().widget('window').loadPage('show_add_otu_project_otu_group_path');
          },
          '.Remove_Selected_from_Group': function (event) {}
        }).call(this,event)
      }
    }
  })
})