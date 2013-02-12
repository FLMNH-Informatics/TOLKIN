/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/27/11
 * Time: 5:14 PM
 * To change this template use File | Settings | File Templates.
 */

//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <image_album>
//= require "catalogs/action_panel"

Module('ImageAlbums', function () {
    JooseClass('Catalog', {
        isa: Templates.Catalog,
        has: {
            dataId: { is: 'ro', init: 'id' },
            columns: { init: function () { return [
                { attribute: "attachment_file_name", width: 250 },
                { attribute: "created_at", width: 250 }
            ] }},
            width: { init: 500},
            showFiller: { is: 'ro', init: false},
            widgets: { is: 'ro', init: function () { return $Reg({
                actionPanel: new ImageAlbums.Catalogs.ActionPanel({ parent: this }),
                //filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this })
            }, this ) } }

        },
        override: {
            //onRowClick: function (event) {
                //var z_fileId = event.element().up('.row').readAttribute('data-id');
                //window.location = this.route('project_chromosome_z_file_path', { id: z_fileId })
            //}
        }
    })
});