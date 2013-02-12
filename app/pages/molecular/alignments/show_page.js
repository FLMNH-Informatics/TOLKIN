//= require <page>
//= require <molecular/alignment>

JooseModule('Molecular.Alignments', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      savable:    { is: 'ro', init: true },
      canRender:  { is: 'ro', init: true },
      title:      { is: 'ro', init: 'Show Alignment' },
      width:      { is: 'ro', init: 900 },
      height:     { is: 'ro', init: 500 },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'project_molecular_alignment_path'
      }, this ) } },
      alignments: { is: 'rw', init: null },
      details:    { is: 'rw', init: [] }
    },
    after: {
    },
    before: {
      initialize: function (){
        var me = this;
        new Ajax.Request('/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/retrieve_alignment_text', {
          method: 'get',
          requestHeaders: {Accept:'application/json'},
          onSuccess: function (response) {
            me.setAlignments(response.responseJSON.alignments_hash);
          }
        })
      }
    },
    methods: {
      selectText: function (element) {
        var doc = document
          , text = doc.getElementById(element);

        if (doc.body.createTextRange) { // ms
          var range = doc.body.createTextRange();
          range.moveToElementText(text);
          range.select();
        } else if (window.getSelection) { // moz, opera, webkit
            var selection = window.getSelection()
             , range = doc.createRange();
            range.selectNodeContents(text);
            selection.removeAllRanges();
            selection.addRange(range);
        }
      },
      onClick: function (event) {
        var elem = event.element()
          , me   = this;
        if (elem.hasAttribute('value')) {
          if (elem.readAttribute('value').startsWith('Generate')){
            var type = elem.readAttribute('value').split(' ')[1].toLowerCase()
              , newelem = '<a href="#" id="view_' + type + '" class="alignment_tab">' + type.capitalize() + '</a>';
/*readnote*/if (type == 'fasta'){ //THIS IS ONLY NECESSARY UNTIL ALIGNMENT CREATION UI IS FINISHED
              me.notifier().working('Generating...')
              new Ajax.Request('/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/alignment_outputs/new', {
                method:         'post',
                requestHeaders: { Accept: 'application/json'},
                parameters:     { 'type': type },
                onSuccess: function (response) {
                  var text = response.responseJSON.alignment_output.alignment_outputs.alignment_text
                  me.notifier().success('Success')
                  $('alignment_text').innerHTML = '</br></br><pre>' + text  + '</pre>'
                  var json = me._alignments.evalJSON()
                  if (!json[type]) json[type] = text
                  me.setAlignments(JSON.stringify(json))
                  if (!$('alignment_control_container').visible()) $('alignment_control_container').toggle()
                  if ($('alignment_main').visible()) $('alignment_main').toggle()
                  makeCurrent(elem)
                  elem.replace(newelem)
                }
              })
            }else{
              me.notifier().warning("Sorry, this option isn't available at this time.");
            }
          }else if (elem.readAttribute('value') == 'Save'){
            me.notifier().working('Updating...')
            elem.disable()
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/update_alignment_info?' + elem.up('form').serialize(), {
              method:         'put',
              requestHeaders: {Accept: 'application/json'},
              onSuccess:  function (response) {
                if (response.responseJSON.alignment) me.notifier().success('Updated successfully!')
                else if (response.responseJSON.error) me.notifier().error(response.responseJSON.error.toString())
              },
              onFailure:  function () { me.notifier().error('Sorry, something went wrong.')},
              onComplete: function () { elem.enable() }
            })
          }
        }
        if (elem.hasAttribute('href') && me._alignments != null ){
          if (elem.hasClassName('alignment_tab')){
            var h = new Hash(me._alignments.evalJSON());
            h.each(function(pair){
              if (pair.key.toString() == elem.innerHTML.toString().toLowerCase()){
                $('alignment_text').innerHTML = '<pre>' + pair.value.toString() + '</pre>'
                makeCurrent(elem)
                if (!$('alignment_control_container').visible()) $('alignment_control_container').toggle()
                if ($('alignment_main').visible()) $('alignment_main').toggle()
              }
            })
          } else if (elem.hasClassName('details_tab')){
            if (!$('alignment_main').visible()) $('alignment_main').toggle()
            if ($('alignment_control_container').visible()) $('alignment_control_container').toggle()
            $('alignment_text').innerHTML = ''
            makeCurrent(elem)
          }
        }

        var tool
        if (elem.hasAttribute('tool')) {
          var tool = elem.readAttribute('tool');
          switch (tool){
            case 'select':
              me.selectText('alignment_text')
            break;
            case 'export':
              window.location = '/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/export?type=' + $$('li.current')[0].id.split('_')[1]
              me.notifier().success('Generating file...')
            break;
            case 'export_fasta':
              me.notifier().working('Generating file...')
              window.location = '/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/export_fasta'
              me.notifier().success('Success')
            break;
//            case 'export_clustal':
//              me.notifier().working('Generating file...')
//              window.location = '/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'] + '/export_clustal'
//              me.notifier().success('Success')
//            break;
            case 'show':
              $('alignment_fasta_display').toggle()
              elem.writeAttribute('value', elem.readAttribute('value').startsWith('Show') ? 'Hide alignment' : 'Show and select CLUSTAL text')
              me.selectText('fasta_text')
            break;
          }
        }
        function makeCurrent(elem){
          $$('.current').each(function(el){el.removeClassName('current')})
          elem.up('li').addClassName('current')
        }
      }
    }
  })
});