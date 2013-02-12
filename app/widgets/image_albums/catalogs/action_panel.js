/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/27/11
 * Time: 5:11 PM
 * To change this template use File | Settings | File Templates.
 */

//= require <widgets/templates/action_panel>

Module('ImageAlbums.Catalogs', function () {
    JooseClass('ActionPanel', {
        isa: Templates.ActionPanel,
        has: {
            buttons: { is: 'ro', init: function () { return [
                { label: 'Add', img: { src: '/images/small_addnew.gif' } },
                { label: 'Delete', img: { src: '/images/small_cross.png' } }
            ] } },
            catalog: {
                is: 'ro',
                init: function () {
                    return this.parent() }
            }
        },
        methods: {
            onClick: function(event) {
                var button = event.element().hasClassName('button') ?  event.element() : event.element().up('.button');
                if(button) {
                    switch(button.down('.label').innerHTML) {
                        case 'Add':
                            var window = this.viewport().widgets().get('window');
                            window.loadPage('sequences_path');
                            window.show();
                            break;
                        case 'Delete':
                            this._parent.selected().destroy(this.context());
                            break;
                    }
                }
            }
        }
    })
});
