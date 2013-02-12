/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 12/6/11
 * Time: 3:57 PM
 * To change this template use File | Settings | File Templates.
 */

//= require <page>
//= require <collections/bulk_upload>
//= require <forms_helper>
//= require <widgets/templates/tooltip>

JooseModule('Collections.BulkUploads', function () {
    JooseClass('IndexPage', {
        isa: Page,
        does: FormsHelper,
        has: {
            canRender: {
                is: 'ro',
                init: true
            },
//            title: {
//                is: 'ro',
//                init: 'Collections Bulk Upload'
//            },
//            height: {
//                is: 'ro',
//                init: 650
//            },
//            width:  {
//                is: 'ro',
//                init: 850
//            },
           /* htmlLoader: {
                is: 'ro',
                init: function () {
                    return $HtmlLoader({
                        pathname: 'project_bulk_uploads_path',
                        paramFunc: function () {
                            return {
                            }
                        }
                    }, this)
                }
            },*/
            templates: { is: 'ro', lazy: true, init: function () { return $Templates([
//                'layouts/window'
            ], this) }}
        },
        override: {
            onDisplay: function () {
                this.dateFieldInit('uploaded_at_date')
                this.SUPER()
            }
        },
        after: {
            initialize: function () {
//                alert('Hello')
            }
        },
        methods: {
            onClick: function (event) {
                if(event.element().id == 'submit_for_mapping') {
                    this.context().viewport().widget('window').loadPage('create_project_bulk_uploads_path');
                    event.stop();
                }
            },
            onSubmitSuccess: function () {
                this.notifier().success('Items successfully uploaded.');
                this.frame().close();
            },

            onSubmitFailure: function () {
                this.notifier().error('Error encountered uploading items.');
            },

            onSubmit: function (event){
                event.stop();
                document.getElementById('bulk_upload_form').target = 'new_bulk_upload_iframe';
                document.getElementById('bulk_upload_form').submit();
                document.getElementById("new_bulk_upload_iframe").onload = function () {
//                    alert('Hello-onload')
                }
            }
        }
    });
});