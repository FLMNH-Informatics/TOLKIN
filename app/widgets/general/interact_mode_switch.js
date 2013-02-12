//= require <lowpro>
//= require <widget>

Module('General', function() {
  JooseClass('InteractModeSwitch', {
    isa: Widget,
    has: {
      context:     { is: 'ro', required: true, nullable: false }
    },
    methods: {
      onClick: Event.delegate({
        '.browse_option': function() {
          var selected = $(this.id()).down('.selected');
          if(selected) {
            selected.removeClassName('selected');
          }
          $(this.id()).down('.browse_option').addClassName('selected');
          this.context().interactMode().set('browse');
        },
        '.edit_option': function() {
          if($(this.id()).down('.selected')) {
            $(this.id()).down('.selected').removeClassName('selected');
          }
          $(this.id()).down('.edit_option').addClassName('selected');
          this.context().interactMode().set('edit');
        }
      })
    }
  })
});