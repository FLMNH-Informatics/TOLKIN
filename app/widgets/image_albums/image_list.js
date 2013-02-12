/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/27/11
 * Time: 5:15 PM
 * To change this template use File | Settings | File Templates.
 */

//= require <widget>
//= require "catalogs/action_panel"

JooseModule('ImageAlbums', function () {
  JooseClass('ImageList', {
    isa: Widget,
    has: {
    //    widgets: { is: 'ro', init: function () { return $Reg({
    //    actionPanel: new ImageAlbums.Catalogs.ActionPanel({ parent: this })
    //  }, this ) } }
    },
    methods: {
      //onClick: function (event) {
      //  var me = this;
      //  Event.delegate({
      //    'img': function (event) {
      //      event.stop();
      //      var window = me.viewport().widget('window');
      //      //window.setURL(me.route('get_image_project_image_path', {id: event.element().readAttribute('data-id')}));
      //      window.loadPage('get_image_project_image_path',{id: event.element().readAttribute('data-id')})
      //      window.show();

//            alert('you only clicked an image')
      //    }
      //  })(event);
      //}
    }
  })
});