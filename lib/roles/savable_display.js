/** section: Widget
 *  class SavableDisplay
**/
Module('TOLJS.role', function() {
  Role('SavableDisplay', {
    methods: {
      working: function() {
        var icon_area = $(this.id()).down('.status_icon_area');
        icon_area.update("<span style='display: none' class='positive'>Saving ...</span>");
        new Effect.Appear(icon_area.down('span'), {
          duration: 0.2,
          queue: 'end'
        })
      },
      success: function() {
        var windowElem = $(this.id()).down('.status_icon_area');
        var icon_area_message = windowElem.down('span');
        new Effect.Fade(icon_area_message, {
          duration: 0.2,
          queue: 'end'
        } );
        windowElem.update("<span style='display: none' class='positive'>Saved</span>");
        icon_area_message = windowElem.down('span');
        new Effect.Appear(icon_area_message, {
          duration: 0.2,
          queue: 'end'
        } );
        new Effect.Fade(icon_area_message, {
          duration: 0.4,
          queue: 'end',
          delay: 2.0
        });
      },
      problem: function() {
        $(this.id()).down('.status_icon_area').update("<span style='display: none' class='negative'>Problem</span>");
      }
    }
  })
});