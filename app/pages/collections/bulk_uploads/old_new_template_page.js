/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 12/12/11
 * Time: 11:04 AM
 * To change this template use File | Settings | File Templates.
 */

//= require <page>
//= require <collections/bulk_upload>
//= require <forms_helper>

JooseModule('Collections.BulkUploads', function () {
    JooseClass('OldNewTemplatePage', {
        isa: Page,
        does: FormsHelper,
        has: {
            canRender: {
                is: 'ro',
                init: true
            },
            title: {
                is: 'ro',
                init: 'Generate Bulk Upload Template'
            },
            height: {
                is: 'ro',
                init: 650
            },
            width:  {
                is: 'ro',
                init: 850
            },
            htmlLoader: {
                is: 'ro',
                init: function () {
                    return $HtmlLoader({
                        pathname: 'new_template_project_bulk_uploads_path',
                        paramFunc: function () {
                            return {
                            }
                        }
                    }, this)
                }
            }
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
                Event.delegate({
                    '#generate_template_submit_button': function (event){

                        event.stop();

                        var taxonAttributes = [];
                        var collectionAttributes = [];
                        var taxonColumns = [];
                        var collectionColumns = [];

                        $$('form#select_elements_for_template input[type=checkbox]').each(function(checkbox){
                            if(checkbox.up().readAttribute('id') == 'taxon_attributes'){
                                if(checkbox.checked) {
                                    taxonAttributes.push(checkbox.up().readAttribute('data-id'));
                                }
                                taxonColumns.push(taxonAttributes);
                            }
                            else if(checkbox.up().readAttribute('id') == 'collection_attributes'){
                                if(checkbox.checked) {
                                    collectionAttributes.push(checkbox.up().readAttribute('data-id'));
                                }
                                collectionColumns.push(collectionAttributes);
                            }
                        })

//                        var search = $$('form.all_search_filter').first().search.value
//                        var term = $$('form.all_search_filter input[type=text]').first().value;

                        var me = this;

                        new Ajax.Request(
                            this.route('generate_template_project_bulk_uploads_path'), {
                                method: 'post',
                                requestHeaders: { Accept: 'text/html' },
                                parameters: {
//                                    'columnAttributes': columnAttributes,
                                    taxonColumns: taxonColumns,
                                    collectionColumns: collectionColumns
//                                    collectionColumns: collectionColumns
//                                    'term': term
                                },

                                onSuccess: function (transport) {
//                                    $('all_probes_list').innerHTML = transport.responseText;
                                }
                            }
                        )
                    }
                }).call(this,event)
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