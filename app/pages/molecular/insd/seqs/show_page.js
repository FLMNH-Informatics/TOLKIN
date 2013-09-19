//= require <page>
//= require <forms_helper>
//= require <templates/tooltip>
//= require <molecular/insd/seq>
//= require <molecular/insd/seqs/taxon_name_auto_text_field>
//= require <molecular/new_mol_marker>
//= require <molecular/get_seqs_from_filename>


JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ShowPage', {
    isa:  Page,
    does: FormsHelper,
    has: {
      records: { is: 'ro', lazy: true, init: function () {
        return $Records({
          seq: new Molecular.Insd.Seq({ id: this.context().params().id, context: this.context() })
        }, this)
      } },
      title:      { is: 'ro', init: "Sequence" },
      width:      { is: 'ro', init: 900 },
      savable:    { is: 'ro', init: true },
      canRender:  { is: 'ro', init: false },
      htmlLoader: { is: 'ro', lazy: true, init: function () {
          return $HtmlLoader({
            pathname: 'project_molecular_sequence_path'
          }, this)
        }
      },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
            taxonNameField: new Molecular.Insd.Seqs.TaxonNameAutoTextField({
              object: this.record('taxon'),
              parent: this.frame()
            })}, this)
        }
      },
      saveButtonText:   { is: 'ro', init: 'Save' },
      closeButton:      { is: 'rw' },
      templates:        { is: 'ro', lazy: true, init: function () { return $Templates([], this) }},
      selectControl:    { is: 'rw' },
      seqIds:           { is: 'rw' },
      fastaFilenameId:  { is: 'rw' },
      currentSeqId:     { is: 'rw' },
      fastaSeqControl:  { is: 'rw' },
      seqCount:         { is: 'rw' }
    },
    after: {
      initialize: function (){
        this.handlers().push( this.frame().on('state:displayed', function (){
          var me = this;
          if (!me._selectControl){
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/new_sequence_marker_select', {
              method: 'get',
              requestHeaders: {Accept:'text/html'},
              onSuccess: function (response) { me.setSelectControl(response.responseText); }
            })
          }
          if (me._seqIds){
            if (!$('fasta_filename_controls').visible()) $('fasta_filename_controls').toggle();
            $('fasta_filename_id').down('option[value="' + me._fastaFilenameId + '"]').writeAttribute({selected: true});
            me.notifier().success('Received sequence(s).');
            if ($$('.saveButton.active')) $$('.saveButton.active')[0].enable();
            if ($$('.saveButton.active')) $$('.saveButton.active')[0].value = "Save";
            $('current_seq_num').innerHTML = (me._seqIds.indexOf(me._currentSeqId) + 1).toString() + ' of ' + me._seqIds.length.toString() + ' sequence(s) for selected file.';
          }
          if (me.iMode()._value == 'edit' && $$('.saveButton.active').first() && $$('.saveButton.active').first().value != 'Save'){ $$('.saveButton.active').first().value = 'Save'; }
        }, this) );
      }
    },
    methods: {
//      willPaginateUpdate : function (event, div) {
//        event.stop();
//
//        new Ajax.Request(event.target.attributes[0].nodeValue, {
//            method: 'get',
//            requestHeaders: { Accept: 'text/html' },
//            onSuccess: function (transport) {
//              $(div).innerHTML = transport.responseText;
//            }
//          }
//        )
//      },
      onChange: function(event) {
        if (event.target == $('seq_sequence')) {
          $('seq_length').value = $('seq_sequence').value.toString().strip().toArray().size().toString();
        }
        if (event.target == $('fasta_filename_id')) {
          this.notifier().working('Querying filename...')
          get_seqs_from_filename(this, event.element().value, $('fasta_seq_display_type').down('input[type="radio"][checked="true"]').value)
        }
      },

      onClick: function(event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            if ($("molecular_insd_seq_taxon_name_auto_input").value == ""){
              this.notifier().error('You must choose a taxon.');
            }else{
              $$('select[name="mol_marker[id]"]').each(function(sel){
                sel.removeAttribute('id')
                sel.writeAttribute('name', sel.readAttribute('name') + '[]')
              })
              var form = $$('form.edit_molecular_insd_seq');
              this.notifier().working('Saving ...');
              form[0].request({
                requestHeaders: {Accept: 'application/json'},
                onSuccess: function (response) {
                  if (response.responseJSON){
                    if (response.responseJSON.errormsg){
                      me.notifier().error(response.responseJSON.errormsg);
                    }else{
                      me.notifier().success('Sequence saved successfully.');
                      if (me._frame._parent._designatedFrame._page._widgets._initial.catalog){
                        //manual reload the outside catalog since can't use syncrecord's fire
                        me.frame().reloadPage();
                        me._frame._parent._designatedFrame._page._widgets._initial.catalog._collection.load();
                      }else{me.frame().close();}

                    }
                  }else {
                    me.notifier().success('Sequence saved successfully.');
                    if (!me._seqIds){
                      me.frame().close();
//                      me.records().get('seq').fire('update', {memo: me.records().get('seq') })
//                      new Molecular.Insd.Seq({ context: me.context() }).fire('update');
                    }else{
                      if (me._frame._parent._designatedFrame._page._widgets._initial.catalog){
                        me._frame._parent._designatedFrame._page._widgets._initial.catalog._collection.load() //manual reload the outside catalog since can't use syncrecord's fire
                      }else{me.frame().close();}
                    }
                  }
                }
              })
            }
          },

          "a#next_fasta_seq": function (event) {
            var currentId     = me._currentSeqId
             ,  currentIndex  = me._seqIds.indexOf(currentId)
             ,  length        = me._seqIds.length
             ,  nextIndex;
            if ((currentIndex + 1)==length){
              nextIndex = 0
            }else{
              nextIndex = currentIndex + 1
            }
            me.notifier().working('Fetching sequence...')
            //todo: this should be in a joose module (but doesn't have to be)
            load_appropriate_seq_page(me, me._seqIds[nextIndex])
          },

          "a#prev_fasta_seq": function (event) {
            var currentId     = me._currentSeqId
             ,  currentIndex  = me._seqIds.indexOf(currentId)
             ,  length        = me._seqIds.length
             ,  prevIndex;
            if (currentIndex == 0){
              prevIndex = length - 1
            }else{
              prevIndex = currentIndex - 1
            }
            load_appropriate_seq_page(me, me._seqIds[prevIndex])
          },

          ".toggle_marker_control": function (event) {
            showMarkerFields(event.element(), me); //located in lib/molecular/new_mol_marker.js
          },

          "a.remove_marker_from_seq": function (event) {
            if (this.iMode()._value == 'edit'){
              if (window.confirm("Remove marker?")){
                var el = event.element()
                  , seq_marker_id = el.up('tr').dataset.sm_id
                  , old_img = el.innerHTML;
                el.innerHTML = '<img src="/images/small_loading.gif" alt="..." />';
                me.notifier().working("Removing marker...");
                new Ajax.Request($('show_seq_form').readAttribute('action') + '/remove_marker', {
                  method:     'post',
                  parameters: { seq_marker_id: seq_marker_id },
                  onSuccess:  function (response) {
                    me.notifier().success(response.responseJSON.msg.toString());
                    el.up('tr').remove();
                    new Molecular.Insd.Seq({ context: me.context() }).fire('update');
                  },
                  onFailure:  function (response) {
                    me.notifier().error('Something went wrong.');
                    el.innerHTML = old_img;
                  },
                  onComplete: function (response) {}
                })
              }
            }
          },

          '#add_new_marker' : function() {
            me.notifier().working('Submitting new marker');
            $('add_new_marker').replace('<img src="/images/ajax-loader.gif" alt="loading..." />');
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/create_marker', {
              parameters:     { marker: $('new_marker_name').value },
              requestHeaders: ["Accept", "application/json"],
              onSuccess: function (response) { me.notifier().success(response.responseJSON.msg.toString()); },
              onFailure: function (response) { me.notifier().error('Something went wrong.'); },
              onComplete: function (response) { me._frame.reloadPage(); }
            })
          },

          '#more_ncbi' : function () {
            $('more_ncbi').innerHTML = ($('more_ncbi').innerHTML == 'show ncbi data') ? 'hide ncbi data' : 'show ncbi data';
            $('unsorted_ncbi').toggle();
          }//,

//          '#all_probes_list a.paginate_link' : function (event) {
//            this.willPaginateUpdate(event, "all_probes_list");
//          },
//          '#assigned_probes_list a.paginate_link' : function (event) {
//            this.willPaginateUpdate(event, "assigned_probes_list");
//          },
//          '#all_probes_list a.next_page' : function (event) {
//            this.willPaginateUpdate(event, "all_probes_list");
//          },
//          '#assigned_probes_list a.next_page' : function (event) {
//            this.willPaginateUpdate(event, "assigned_probes_list");
//          },
//          '#all_probes_list a.previous_page' : function (event) {
//            this.willPaginateUpdate(event, "all_probes_list");
//          },
//          '#assigned_probes_list a.previous_page' : function (event) {
//            this.willPaginateUpdate(event, "assigned_probes_list");
//          },
//          '.all_search_button': function (event) {
//            var search = $$('form.all_search_filter').first().search.value;
//            var term   = $$('form.all_search_filter input[type=text]').first().value;
//            var me     = this;
//
//            new Ajax.Request(
//              this.route('search_project_molecular_sequences_path'), {
//                method: 'get',
//                requestHeaders: { Accept: 'text/html' },
//                parameters: {
//                  'search': search,
//                  'term': term
//                },
//
//                onSuccess: function (transport) {
//                  $('all_probes_list').innerHTML = transport.responseText;
//                }
//              }
//            )
//          },
//          '.assigned_search_button': function (event) {
//            var search = $$('form.assigned_search_filter').first().search.value;
//            var term   = $$('form.assigned_search_filter input[type=text]').first().value;
//            var me     = this;
//
//            new Ajax.Request(
//              this.route('assigned_search_project_molecular_sequences_path'), {
//                method: 'get',
//                requestHeaders: { Accept: 'text/html' },
//                parameters: {
//                  'id': params.id,
//                  'search': search,
//                  'term': term
//                },
//
//                onSuccess: function (transport) {
//                  $('assigned_probes_list').innerHTML = transport.responseText;
//                }
//              }
//            )
//          },
//          '.button_img': function (event) {
//            switch (event.element().readAttribute('value')) {
//              case 'Assign':
//                var probeIds = [];
//                $$('form.assign_image_form input[type=checkbox]').each(function(checkbox) {
//                  if (checkbox.checked){
//                    probeIds.push(checkbox.up().readAttribute('data-id'));
//                  }
//                })
//                var me = this;
//
//                new Ajax.Request(
//                  this.route('assign_probe_to_insd_seq_project_molecular_sequence_path'), {
//                    method: 'post',
//                    requestHeaders: { Accept: 'text/html' },
//                    parameters: {
//                      'probeIds[]': probeIds
//                    },
//
//                    onSuccess: function (transport) {
//                      $$('form.assign_image_form input[type=checkbox]').each(function(checkbox) {
//                        if (checkbox.checked) {
//                          checkbox.checked = false;
//                        }
//                      })
//                      $('assigned_probes_list').innerHTML = transport.responseText;
//                      me.notifier().success('Probe(s) assigned successfully');
//                    }
//                  }
//                )
//                break;
//
//              case 'Remove':
//                var probeIds = [];
//                $$('form.remove_image_form input[type=checkbox]').each(function(checkbox) {
//                  if (checkbox.checked) {
//                    probeIds.push(checkbox.up().readAttribute('data-id'));
//                  }
//                })
//                var me = this;
//                new Ajax.Request(
//                  me.route('remove_probe_from_insd_seq_project_molecular_sequence_path'), {
//                    method: 'post',
//                    requestHeaders: { Accept: 'text/html' },
//                    parameters: {
//                      'probeIds[]': probeIds
//                    },
//                    onSuccess: function (transport) {
//                      $$('form.remove_image_form input[type=checkbox]').each(function(checkbox) {
//                        if (checkbox.checked) {
//                          checkbox.checked = false;
//                        }
//                      })
//                      $('assigned_probes_list').innerHTML = transport.responseText;
//                      me.notifier().success('Probe(s) removed successfully');
//                    }
//                  }
//                )
//                break;
//            }
//          }
        }).call(this, event)
      }

//      onRowClick: function (event) {
//        var probeId = event.element().up('.row').readAttribute('data-id');
//        window.location = this.route('project_chromosome_probe_path', {
//          id: probeId
//        });
//      },
//      onMouseover: function (event) {
//        var me = this;
//        Event.delegate({
//          ".sortable.row": function (event) {
//            var probeId = event.element().up('.sortable.row').readAttribute('data-id');
//            if (probeId != me.lastHoverId) {
//              me.lastHoverId = probeId;
//              me.widget('tooltip').move(event.pointer()).update('loading ...').show();
//              me.widget('tooltip').waitingForId = probeId;
//              clearTimeout(me.hoverTimer);
//              me.hoverTimer = setTimeout(function () {
//                new Ajax.Request(me.route('tooltip_show_project_chromosome_probe_path', {id: probeId}), {
//                    method: 'get',
//                    requestHeaders: {Accept: 'text/html' },
//                    parameters: { probeId: probeId },
//                    onSuccess: function (transport) {
//                      if (me.widget('tooltip').waitingForId == probeId) {
//                        if (me.widget('tooltip').visible()) {
//                          me.widget('tooltip').update(transport.responseText);
//                        }
//                      }
//                    }
//                  }
//                )
//              }, 1500)
//            }
//          },
//          ".imageSingle": function (event) {
//            var probeId = event.element().readAttribute('data-id');
//            if (probeId != me.lastHoverId) {
//              me.lastHoverId = probeId;
//              me.widget('tooltip').move(event.pointer()).update('loading ...').show();
//              me.widget('tooltip').waitingForId = probeId;
//              clearTimeout(me.hoverTimer);
//              me.hoverTimer = setTimeout(function () {
//                new Ajax.Request(me.route('tooltip_show_project_chromosome_probe_path', { id: probeId }), {
//                  method: 'get',
//                  requestHeaders: { Accept: 'text/html' },
//                  parameters: { probeId: probeId },
//                  onSuccess: function (transport) {
//                    if (me.widget('tooltip').waitingForId == probeId) {
//                      if (me.widget('tooltip').visible()) {
//                        me.widget('tooltip').update(transport.responseText);
//                      }
//                    }
//                  }
//                })
//              }, 1500)
//            }
//          }
//        }).call(this, event)
//      },
//      onMouseout: function (event) {
//        var me = this;
//        Event.delegate({
//          ".sortable.row": function (event) {
//            me.widget('tooltip').hide();
//          },
//          ".imageSingle": function (event) {
//            me.widget('tooltip').hide();
//          }
//        }).call(this, event)
//      }

    }
  })
})
