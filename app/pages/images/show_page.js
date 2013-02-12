/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/13/11
 * Time: 3:36 PM
 * To change this template use File | Settings | File Templates.
 */


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
            height: {
                is: 'ro',
                init: 565
            },
            width:  {
                is: 'ro',
                init: 590
            },
            htmlLoader: {
                is: 'ro',
                init: function () {
                    return $HtmlLoader({
                        pathname: 'get_image_project_image_albums_path',
                        paramFunc: function () {
                            return {
                                imageId: this.params().id
                            }
                        }
                    }, this)
                }
            },
            image: { is: 'ro', lazy: true, init: function () { return(
                new ImageSolo({ id: params.id, context: this.context()})
                )}}//,
//            templates: { is: 'ro', lazy:true, init:function() { return $TSet([
//                //'library/publications/catalogs/_action_panel',
//                'filters/_form',
//                'layouts/window'
////                'image_albums/get_image'
//            ], this) } }
        },
        before: {
            // ChrisG - 4/4/2011 - necessary right now because seq contig is overriding id in params
            initialize: function () {
                //alert('hello')
                //this._id = this.params().id
            }
        },
        methods: {
            onSubmit: function (event) {
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
                            //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
                        }
                    })
                }
            },

//            onClick: function(event) {
//                event.stop();
//                var me = this;
//                var form = event.element();
//                Event.delegate({
//                    '.edit_save_button': function(event) {
//                        if(me.context().currentSelection()) {
////                            me._imageClick(event);
//                            me.context().notifier().working('Saving ...');
//                            event.element().request({
//                                requestHeaders: {
//                                    Accept: 'application/json'
//                                }
//                            })
////                            new Ajax.Request(form.readAttribute('action'), {
////                                method: form.readAttribute('method'),
//////                                parameters: formData,
////                                requestHeaders: { Accept: 'application/json' },
////                                onSuccess: function(transport) {
//////                                    me.records().get('image').update(Object.values(transport.responseJSON).first(), { request: false });
////                                    me.context().notifier().success('Saved.');
////                                    //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
////                                }
////                            })
//                        } else {
//                            //this.context().on(
//                            //    'current_selection:loaded',
//                            //    function () { me._onNodeNameClick(event) },
//                            //    { once: true }
//                            //)
//                        }
//                    }
//                }).bind(this)(event);
//            }//,

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
//                                ImageList.fire('recordUpdated')
//                                me.frame().close()
                                me.notifier().success('Image was successfully updated!')
                            },
                            onFailure: function (transport) {
                                var response = transport.responseText
                                me.notifier().failure(response)
                            }
                        })

//                        if(form.readAttribute('class') == 'image_show') {
//                            event.stop();
//                            var formData = $$('.image_show').inject({}, function (out, form) {
//                                return(
//                                    Object.extend(
//                                        out,
//                                        form.serialize({ hash: true, submit: false }))
//                                    )
//                            }, this)
//                            var me = this;
//                            this.context().notifier().working('Saving ...');
//                            new Ajax.Request(form.readAttribute('action'), {
//                                method: form.readAttribute('method'),
//                                parameters: formData,
//                                requestHeaders: { Accept: 'application/json' },
//                                onSuccess: function(transport) {
//                                    me.records().get('image').update(Object.values(transport.responseJSON).first(), { request: false });
//                                    me.context().notifier().success('Saved.');
//                                    //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
//                                }
//                            })
//                        }

                    }
                }).bind(this)(event)
            }//,


        }
    })
});
