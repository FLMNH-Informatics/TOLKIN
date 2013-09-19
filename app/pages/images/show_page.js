//= require <page>
//= require <image_albums/image_list>
//= require <image_solo>
//= require <forms_helper>

JooseModule('Images', function () {
    JooseClass('ShowPage', {
        isa: Page,
        does: FormsHelper,
        has: {
            savable: { is: 'ro', init: true },
            canRender: { is: 'ro', init: true },
            title:  { is: 'ro', init: 'Image : Show' },
            height: { is: 'ro', init: 565 },
            width:  { is: 'ro', init: 590 },
            htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
                        pathname: 'get_image_project_image_albums_path',
                        paramFunc: function () { return { imageId: this.params().id } }
                    }, this)
                }
            },
            image: { is: 'ro', lazy: true, init: function () { return(
                new ImageSolo({ id: params.id, context: this.context()})
                )}}
        },
        methods: {
            onSubmit: function (event) {
              event.stop();
                var form = event.element();
                if(form.readAttribute('class') == 'species_page_form') {
                    event.stop();
                    var formData = $$('.species_page_form').inject({}, function (out, form) {
                        return(
                            Object.extend(
                                out,
                                form.serialize({ hash: true, submit: false }))
                            )
                    }, this)
                    var me = this;
                    this.context().notifier().working('Saving ...');
                    new Ajax.Request(form.readAttribute('action'), {
                        method: form.readAttribute('method'),
                        parameters: formData,
                        requestHeaders: { Accept: 'application/json' },
                        onSuccess: function(transport) {
                            me.records().get('taxon').update(Object.values(transport.responseJSON).first(), { request: false });
                            me.context().notifier().success('Saved.');
                        }
                    })
                }
            },

            onClick: function (event) {
                var me = this;
                var image_id = this.params().id
                Event.delegate({
                    '.saveButton.active': function (event) {
                        var form = event.element().up('.dialog').down('.update_image_form');
                        form.request({
                            parameters: {id: image_id},
                            requestHeaders: {
                                Accept: 'application/json'

                            },
                            onSuccess: function () {
                                me.notifier().success('Image was successfully updated!')
                            },
                            onFailure: function (transport) {
                                var response = transport.responseText
                                me.notifier().failure(response)
                            }
                        })
                    }
                }).bind(this)(event)
            }
        }
    })
});
