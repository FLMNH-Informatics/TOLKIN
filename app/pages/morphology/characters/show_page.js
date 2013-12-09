//= require <page>
//= require <morphology/character>

JooseModule('Morphology.Characters', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      title: {is: 'ro', init: 'Morphology Character: Show'},
      height: { is: 'ro', init: 350 },
      width: { is: 'ro', init: 700 },
      characterId: { is: 'rw', init: function(){return params['id']}}//,
      //don't need any templates, don't see where they're being used
//      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
//        'widgets/catalogs/_entry',
//        'layouts/window'  ], this) }
//      }
//      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
//        pathname: 'project_morphology_character_path'
//      }, this)}}
    },
    methods: {
      validateEdit: function (fn){if(this.interactMode()._value == 'edit' ){
        if (!$('character_was_deleted')){
          if(!$('character_was_superceded') || params["matrix_id"]){
            fn()
          }else{
            this.notifier().warn('This character has been superceded, editing is not possible.')
          }
        }else{this.notifier().warn('This character has been deleted, editing is not possible.')}
      }else{
        this.notifier().warn('You must be in edit mode to complete this action.')}
      },
      toggleNewState: function () {
        var newButtonText = $('new_character_state').innerHTML == "New State" ? "Hide" : "New State";
        if (newButtonText == "New State"){ $("add_new_row").setStyle({visibility: 'hidden'}); }else{ $("add_new_row").setStyle({visibility: 'visible'}); }
        $('new_character_state').innerHTML = newButtonText;
        $('new_state_name').value = "";
        $('morphology_chr_state_polarity').selectedIndex = 0;
        $('morphology_chr_state_description').value = "";
      },
      onClick: function (event) {
        var me = this;
        Event.delegate({
        //edit character
          '#edit_character': function (event) {
            me.validateEdit(function(){ me.frame().viewport().widget('window').loadPage('edit_project_morphology_character_path', {id: me._characterId}) });
          },
        //citations
          '.add_citation': function (event) {
            me.validateEdit(function(){ me.frame().viewport().widget('window').loadPage('show_add_citation_project_morphology_character_path', {id: me._characterId})})
          },
          '.citation_edit': function (event) {
            me.validateEdit(function(){
              me.frame().viewport().widget('window').loadPage('project_library_citation_path', {id: event.element().dataset.citationId, project_id: params['project_id']})
            })
          },
          '.citation_remove': function (event){
            me.validateEdit(function(){
              if(confirm('Are you sure you want to remove this citation?')){
                me.notifier().working('removing citation...');
                new Ajax.Request(window.location.pathname + '/remove_citation?citation_id=' + event.element().dataset.citationId.toString(), {
                  requestHeaders: ["Accept", "application/json"],
                  onSuccess: function (transport){
                    var msg = transport.responseJSON.msg;
                    if (msg.startsWith('Err')){
                      me.notifier().error(msg.toString())
                    }else if (msg == 'old'){
                      event.element().up('div.citation').remove();
                      me.notifier().success('Citation removed.');
                    }else if (msg.startsWith('You')){
                      me.notifier().warning(msg);
                    }else if (msg == 'ok'){
                      me.notifier().error('Something went wrong');
                    }else{
                      window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + transport.responseJSON.msg.toString();
                    }
                  }
                })
              }
            })
          },
        //states
          '#new_character_state': function(event){ me.validateEdit(function(){me.toggleNewState();}) },
          '#create_new_state': function(event) {
            event.stop();
            $('create_new_state').disabled = true;
            var form = $('new_morphology_chr_state');
            me.notifier().working('Creating state...')
            form.request({
              requestHeaders:["Accept", "application/json"],
              onSuccess: function(transport){
                if (transport.responseJSON.partial){
                  me.notifier().success('State created.');
                  $('existing_states').insert({bottom: transport.responseJSON.partial});
                  me.toggleNewState();
                  $('create_new_state').disabled = false;
                }
                if (transport.responseJSON.msg){me.notifier().error(transport.responseJSON.msg)}
                if (transport.responseJSON.new_character){window.location = "/projects/" + params["project_id"] + "/morphology/characters/" + transport.responseJSON.new_character.character.id.toString()}
              },
              onFailure: function (transport){ me.notifier().error('something went wrong')}
            })
          },
          '.character_chr_state_edit': function (event) {
            me.validateEdit(function(){
              me.frame().viewport().widget('window').loadPage('edit_project_morphology_character_chr_state_path', {character_id: me._characterId, id: event.element().dataset.chrStateId});
            })
          },
          '.character_chr_state_remove': function (event) {
            me.validateEdit(function(){
              if (confirm('Are you sure you want to remove this state?')){
                var stateId = event.element().dataset.chrStateId
                  , characterId = event.element().dataset.characterId;
                me.notifier().working('Removing state...');
                new Ajax.Request('/projects/' + params['project_id'] + '/morphology/characters/' + characterId.toString() + '/remove_state?chr_state_id=' + stateId.toString(), {
                  requestHeaders: ['Accept', 'application/json'],
                  onSuccess: function(transport){
                    if (transport.responseJSON.msg.startsWith('Err')){
                      me.notifier().error(transport.responseJSON.msg.toString());
                    }else if (transport.responseJSON.msg == 'old'){
                      $('chr_state_table_' + stateId.toString()).remove();
                      me.notifier().success('State removed.');
                    }else if (transport.responseJSON.msg.startsWith("You")){
                      me.notifier().warning(transport.responseJSON.msg);
                    }else if (transport.responseJSON.msg == "ok"){
                      me.notifier().error('something went wrong')
                    }else{
                      window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + transport.responseJSON.msg.toString();
                    }
                  },
                  onFailure: function (transport){ me.notifier().error('Something went wrong.')}
                })
              }
            })
          },
          '.add_citation_to_state': function (event) {
            var chrStateId = event.element().dataset.stateId;
            me.validateEdit(function(){ me.frame().viewport().widget('window').loadPage('show_add_citation_project_morphology_character_chr_state_path', {character_id: me._characterId, id: chrStateId})})
          },
          '.state_citation_edit': function (event) {
//            var citationId = event.element().up('div.citation').dataset.citation_id;
//            me.validateEdit(function(){
//              if (event.element().nodeName != "A") me.frame().viewport().widget('window').loadPage('project_library_citation_path', {id: citationId, project_id: params['project_id']})
//            });
          },
          '.state_citation_remove': function (event) {
            var citationId = event.element().up('div.citation').dataset.citation_id
              , stateId = event.element().up('td').dataset.state_id
              , characterId = event.element().up('td').dataset.character_id;
            if (confirm('Are you sure you want to remove this citation?')){
              me.notifier().working('Removing citation...');
              var pathname = window.location.pathname + (stateId ? '/chr_states/' + stateId : '') + '/remove_citation?citation_id=' + citationId
              new Ajax.Request(pathname, {
                requestHeaders: ["Accept", "application/json"],
                onSuccess: function (transport) {
                  if (transport.responseJSON.msg.startsWith('Err')){
                    me.notifier().error(transport.responseJSON.msg.toString());
                  }else if (transport.responseJSON.msg == 'old'){
                    event.element().up('div').remove();
                    me.notifier().success('Citation removed.');
                  }else if (transport.responseJSON.msg.startsWith("You")){
                    me.notifier().warning(transport.responseJSON.msg);
                  }else if (transport.responseJSON.msg == "ok"){
                    me.notifier().error('something went wrong')
                  }else{
                    window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + transport.responseJSON.msg.toString();
                  }
                },
                onFailure: function(transport){me.notifier().error('Something went wrong.')}
              })
            }
          },
          '.add_image_to_state': function (event) {
            var chrStateId = event.element().dataset.stateId;
            me.validateEdit(function(){me.frame().viewport().widget('window').loadPage('show_add_image_project_morphology_character_chr_state_path', {character_id: me._characterId, id: chrStateId})})
          },
          '.remove_image_from_chr_state': function (event) {
            me.validateEdit(function(){
              if (confirm('Do you want to remove the image?')){
                var imageId = event.element().dataset.imgId
                  , stateId = event.element().dataset.chrStateId;

                me.notifier().working('Removing image...');
                new Ajax.Request(window.location.pathname + '/chr_states/' + stateId.toString() + '/remove_image?image_id=' + imageId.toString(), {
                  requestHeaders: ['Accept', 'application/json'],
                  onSuccess: function(transport){
                    var msg = transport.responseJSON.msg;

                    if (msg.startsWith('Err') || msg.startsWith('You')){ me.notifier().error(msg); }
                    else if (msg == 'old'){
                      $('chr_state_image_' + imageId.toString()).remove();
                      me.notifier().success('Image removed.');
                    }else{
                      window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + msg.toString();
                    }
                  },
                  onFailure: function(transport){
                    me.notifier().error('Something went wrong');
                  }
                })
              }
            })
          },
        //images
          '.remove_image_from_character': function (event) {
            me.validateEdit(function(){
              if (confirm('Do you want to remove the image?')){
                var imageId = event.element().dataset.imgId
                  , characterId = event.element().dataset.characterId;

                me.notifier().working('Removing image...');
                new Ajax.Request('/projects/' + params['project_id'] + '/morphology/characters/' + characterId.toString() + '/remove_image?image_id=' + imageId.toString(), {
                  requestHeaders: ['Accept', 'application/json'],
                  onSuccess: function(transport){
                    var msg = transport.responseJSON.msg;
                    if (msg.startsWith('Err') || msg.startsWith('You')){ me.notifier().error(msg.toString());}
                    else if (msg == 'old'){
                      $('image_' + imageId.toString()).remove();
                      me.notifier().success('Image removed.');
                    }else{
                      window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + msg.toString();
                    }
                  },
                  onFailure: function(transport){me.notifier().error('something went wrong')}
                })
              }
            })
          },
          '#attach_character_image': function (event) {
            event.stop();
            me.validateEdit(function(){
              if ($('character_uploaded_data').files.length > 0){
                me.notifier().working('Uploading image...')
                event.element().up('form').submit();
              }
              else{me.notifier().warning('You must choose a file')}
            })
          },
        //tab navigation
          '.unselected': function (event){
            event.stop();
            var divSelected = $$('.morphology_selected')[0];
            var spanSelected = $$('.selected.head')[0];
            var el, divId;
            var divHeight = $$('.morphology_character_info')[0].getHeight();
            if (event.element().nodeName == "SPAN"){
              el = event.element();
            }else{
              el = event.element().up('span');
            }
            divId = el.down('a').id.split('_')[1] + '_' + el.down('a').id.split('_')[2];
            divSelected.toggleClassName('morphology_selected');
            divSelected.toggleClassName('morphology_unselected');
            if ($(divId).getHeight() < divHeight) $(divId).setStyle({height: divHeight.toString() + 'px'})
            spanSelected.toggleClassName('selected');
            spanSelected.toggleClassName('unselected');
            $(divId).toggleClassName('morphology_unselected');
            $(divId).toggleClassName('morphology_selected');
            el.toggleClassName('selected');
            el.toggleClassName('unselected');
          }
        }).call(this,event)
      }
    }
  })
})