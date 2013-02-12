//= require <page>

JooseModule('Molecular.Markers', function () {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender:    { is: 'ro', init: false },
      originalRows: { is: 'rw', init: {} }
    },
    after: {
      onLoad: function(){
        $('title_and_controls').setStyle({'width': $('markers_table').down('table').getWidth().toString() + 'px'});
        this.setTableHeaderSize($$('tr[data-marker-id]')[0]);
      }
    },
    methods: {
      setTableHeaderSize: function (row) {
        if (row){
          var tdArray = row.select('td');
          $('title_and_controls').setStyle({'width': (row.getWidth()+3).toString() + 'px'})
          $$('td.h').each(function(td, i){
            if(!td.hasClassName('check_head')){
              var width = (tdArray[i].getWidth() - 6).toString() + 'px'; //subtract 6 to adjust for h class's extra 3px padding per side
              td.setStyle({'width': width})
            }
          });
        }else{
          $('markers_table').down('tbody').insert({bottom: '<tr><td colspan=6 style="width:150px;">No Markers Present</td></tr>'});
          $('title_and_controls').setStyle({'width': '250px'})
          $('markers_table').down('table').setStyle({'padding-top': '45px'});
        }
      },
      onClick: function(event){
        var me = this;
        Event.delegate({
          '.marker_seqs_connections': function(event){
            var markerId = event.element().readAttribute('data-marker-id');
            me.frame().viewport().widget('window').loadPage('display_seqs_project_molecular_marker_path', {id: markerId});
          },
          '.marker_timelines_connections': function(event){
            var markerId = event.element().readAttribute('data-marker-id');
            me.frame().viewport().widget('window').loadPage('display_matrices_project_molecular_marker_path', {id: markerId})
          },
          '.marker_primers_connections': function(event){
            var markerId = event.element().readAttribute('data-marker-id');
            me.frame().viewport().widget('window').loadPage('display_primers_project_molecular_marker_path', {id: markerId})
          },
          '.edit_marker':   function (event){
              if(me.interactMode()._value == "edit"){
                var markerId   = event.element().up().readAttribute('data-marker-id')
                  , className  = event.element().up('tr').className
                  , markerName = event.element().up().previous(4).innerHTML
                  , markerGene = event.element().up().previous(3).innerHTML
                  , seqs       = event.element().up().previous(2).innerHTML
                  , timelines  = event.element().up().previous(1).innerHTML
                  , primers    = event.element().up().previous(0).innerHTML
                  , markerTypeSelect = $('marker_type').clone(true).writeAttribute({id: $('marker_type').id + markerId})
                  , newTr = "<tr class='edit_row " + className + "' data-marker-id='" + markerId +"'>" +
                            "<td></td>" +
                            "<td><input type='text' name='marker[name]' value='"+ markerName + "'></td>" +
                            "<td>" + markerTypeSelect.outerHTML + "</td>" +
                            "<td class='td_divider'>" + seqs + "</td>" +
                            "<td class='td_divider'>" + timelines + "</td>" +
                            "<td class='td_divider'>" + primers + "</td>" +
                            "<td class='td_divider' style='font-size:80%;'>(<a class='save' href='#'>save</a>)(<a class='cancel' href='#'>cancel</a>)</td>";
                this._originalRows['marker' + markerId] = event.element().up('tr');
                event.element().up('tr').replace(newTr);
                me.setTableHeaderSize($$('.edit_row.'+className)[0]);
                $('marker_type' + markerId).down('[value="'+(markerGene=="unlisted" ? '' : markerGene)+'"]').writeAttribute({selected: true});
              }else{me.notifier().warn("You must be in 'Edit Mode' to complete this action.")}
          },
          'input:checkbox': function (event) { me.shiftCheck(event); },
          '.delete_marker': function (event){
              var markerId = event.element().up().readAttribute('data-marker-id')
                , td = event.element().up('tr').down('td')
                , confirmed = confirm('Do you wish to delete the selected marker?  Any associated matrices or sequences will lose their association.')

              if (confirmed){
               new Ajax.Request(window.location.pathname + '/' + markerId + '/destroy', {
                 method: 'put',
                 onSuccess: function(response){
                   if (response.responseJSON.error){
                     me.notifier().error(response.responseJSON.error.toString())
                   }else{
                     me.notifier().success('Marker deleted.')
                     td.up('tr').remove()
                   }
                 },
                 onFailure: function(){
                   me.notifier().error("Something went wrong.")
                 }
               })
              }
          },
          '.cancel': function (event){
              var markerId = event.element().up('tr').readAttribute('data-marker-id')
                , oldTr = this._originalRows['marker' + markerId];
              event.element().up('tr').replace(oldTr);
              me.setTableHeaderSize($$('tr[data-marker-id="'+markerId+'"]')[0]);
          },
          '.save': function (event){
              var td = event.element().up('tr').down('td');
              if (td.innerHTML == ""){
                var markerId = event.element().up('tr').readAttribute('data-marker-id')
                  , name = event.element().up().previous(3).down().value
                  , type = event.element().up().previous(2).down().value;
                td.insert({bottom: new Element('img', {'src': '/images/ajax-loader.gif', 'alt': 'saving...'} )});
                me.notifier().working('Saving...')
                new Ajax.Request(window.location.pathname + '/' + markerId, {
                  method: 'post',
                  parameters: { 'name': name, 'type': type },
                  onSuccess: function (response) {
                    event.element().up('tr').replace(response.responseJSON.row)
                    me.notifier().success('Updated marker.')
                  },
                  onFailure: function (response) {
                    me.notifier().error('Something went wrong.')
                  }
                })
              }
          },
          'input:button': function (event){
            if(this.interactMode()._value == "edit"){
              var checks = $$('input:checkbox[checked=true]')
              switch(event.element().readAttribute('value')){
                case 'Delete Selected':
                  if (checks.length > 0){
                    var confirmed = confirm('Do you wish to delete the ' + checks.length.toString() + ' selected markers?  Any associated matrices or sequences will lose their association.')
                    if (confirmed){
                      me.notifier().working('Deleting markers...')
                      new Ajax.Request(window.location.pathname + "/delete_selected", {
                        method: 'put',
                        parameters: {'ids': checks.map(function(check){return check.up('tr').dataset.markerId;}).join(',')},
                        onSuccess: function(response){
                          if(response.responseJSON.success){
                            me.notifier().success('Markers deleted.');
                            checks.each(function(check){check.up('tr').remove()});
                          }
                        }
                      })
                    }
                  }else{me.notifier().warning('You must choose at least one marker.')}
                break;
                case 'Merge':
                  if(checks.length == 2){
                    var firstMarker = {id: checks[0].dataset.markerId, name: checks[0].dataset.markerName}
                      , secondMarker= {id: checks[1].dataset.markerId, name: checks[1].dataset.markerName};

                    if (firstMarker.name.toLowerCase() == secondMarker.name.toLowerCase()){
                      me.notifier().working('Merging markers with same name...')
                      new Ajax.Request(window.location.pathname + "/merge", {
                        method: 'post',
                        parameters: { id1: firstMarker.id, id2: secondMarker.id},
                        onSuccess: function(response){
                          if (response.responseJSON.msg){
                            me.notifier().warning("Problem merging markers: " + response.responseJSON.msg)
                          }else if (response.responseJSON.row){
                            checks[0].up('tr').replace(response.responseJSON.row);
                            checks[1].up('tr').remove();
                            me.notifier().success('Markers sucessfully merged.')
                          }
                        }
                      })
                    }else{
                      me.notifier().warning('You may only merge markers with matching names. ' + firstMarker.name.toLowerCase() + " is not the same as " + secondMarker.name.toLowerCase() + ".")
                    }
                  }else{me.notifier().warning('You may only merge two markers at once.  Please select only two.')}
                break;
              }
          }else{me.notifier().warn("You must be in 'Edit Mode' to complete this action.")}
          }
        }).call(this,event)
      }
    }
  })
})