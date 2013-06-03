JooseRole('NewUpload', {
  has: { currentTolkinHeading: {is: 'rw', init: null} },

  after: {
    initialize: function () {
      $('upload').enable();
      $$('.map_type').each(function(radio){radio.enable();});
      var me = this
        , file_headings = $$('.header_container')
        , tolkin_headings = $$('.tolkin_headings').first().select('option');

      tolkin_headings.each(function(option){
        var heading = option.value;
        file_headings.each(function(file_head){
          if (file_head.dataset.userheader.toLowerCase() == heading.toLowerCase()){
            var box = file_head.down('.tolkin_header');
            option.setAttribute('data-header', heading);
            box.setAttribute('data-header', heading);
            box.innerHTML = me._cancelHeading() + heading;
            option.disabled = true;
          }
        })
      })
    }
  },

  methods:{
    _cancelHeading: function (){
      return '<a class="cancel_map">[x]</a>';
    },

    enableOption: function (optionText){
      $$('option[data-header="' + optionText + '"]').first().disabled = false;
    },

    onClick: function (event){
      var me = this;
      Event.delegate({

        '.clear_headings': function(){
          $$('.tolkin_headings').first().select('option').each(function(option){option.disabled = false})
          $$('.tolkin_header').each(function(head){head.innerHTML = ''; head.removeAttribute('data-header')})
        },

        '.tolkin_headings': function (){
          if (event.element().nodeName == "OPTION" && event.element().disabled != true){
            var option = event.element()
            option.setAttribute('data-header', option.text)
            me.setCurrentTolkinHeading(option)
          }
        },
        '.tolkin_header': function(){
          if (me._currentTolkinHeading != null){
            if (me._currentTolkinHeading.nodeName == "OPTION"){
              if (event.element().innerHTML != ""){
                me.enableOption(event.element().dataset.header);
              }
              event.element().setAttribute('data-header', me._currentTolkinHeading.text);
              event.element().innerHTML = me._cancelHeading() + me._currentTolkinHeading.text;
              me._currentTolkinHeading.disabled = true;
              me.setCurrentTolkinHeading(null);
            }
          }
        },

        '.cancel_map': function (){
          var heading = event.element().up().dataset.header;
          event.element().up().innerHTML = "";
          me.enableOption(heading);
        },

        '.view_map': function (){
          me.notifier().working('Fetching map')
          new Ajax.Request(me.context().routes().pathFor('view_map_project_' + me._partialPath + '_path'), {
            method: 'get',
            parameters: { 'map_id': $('map').value },
            onSuccess: function (transport){
              me.notifier().success('Map received.')
              $('view_map_container').innerHTML = transport.responseText;},
            onFailure: function (transport){
              me.notifier().error('Sorry, something went wrong fetching map.')
            }
          })
        },

        '.delete_map': function(){
          if (confirm('Are you sure you want to destroy this map?')){
            var mapId = $('view_map_container').down('table').dataset.id;
            me.notifier().working('Deleting map...')
            new Ajax.Request(me.context().routes().pathFor('project_custom_mapping_path', {id: mapId}),{
              method: 'delete',
              onSuccess: function(){
                $$('option[value='+mapId+']').first().remove();
                $('view_map_container').innerHTML = '';
                me.notifier().success('Successfully deleted map.')
              },
              onFailure: function(){
                me.notifier().error('Something went wrong trying to delete map')
              }
            })
          }
        }
      }).call(this,event)
    },

    onChange: function (event){
      Event.delegate({
        '.map_type':function(){
          $w('new_map existing_map').each(function(id){$(id).toggle();});
        }
      }).call(this,event)
    },

    onSubmit: function (event) {
      event.stop();
      var me = this
        , map = {}
        , type = $$('input[type="radio"]:checked').first().value;

      if ($('name').value == "" && type == 'new'){
        me.notifier().warn('You must submit a name for the map');
      }else if (type=='new' && $('taxon_headings') != null && !$('taxon_headings').down('option[value="taxon[name]"]').hasAttribute('disabled') && !confirm('Do you wish to save without assigning these records a Taxon? You must choose a name field to assign a Taxon.')){
        //do_nothing (silly)
      }else{
        $('upload').disable();
        if(type == "new"){
          $$('.tolkin_header').each(function(tol_head){
            var tolkin_head = tol_head.dataset.header
              , user_head    = tol_head.dataset.userheader;
            map[user_head] = tolkin_head || '';
          });
        }
        me.notifier().working('Processing file...')
        new Ajax.Request(me.context().routes().pathFor('bulk_upload_project_' + me._partialPath + '_path'),{
          method: 'post',
          parameters: {
            'map': Object.toJSON(map),
            'name': $('name').value,
            'filename': $('filename').value,
            'type': $$('input[type="radio"]:checked').first().value,
            'map_id': $('map') && $('map').value,
            'taxon': ($('taxon_headings') != null)
          },
          onSuccess: function (transport){
            me.notifier().success('Data processed.');
            if (transport.responseText.startsWith('<')){
              $('errors_container').insert({top: transport.responseText});
              me.notifier().error('Errors encountered.')
            }else{
             me.notifier().working('Data processed.  Redirecting to catalog...')
             window.location = me.context().routes().pathFor('project_' + me._partialPath + '_path')
            }
          },
          onFailure: function (transport){
            $('upload').enable();
            me.notifier().error('Something went wrong.')
          }
        })
      }
    }
  }
})
