//= require <page>
//= require <html_loader>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ShowCreateAlignmentPage', {
    isa: Page,
    has:    {
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_create_alignment_project_molecular_sequences_path'
      }, this ) } },
      title:          { is: 'ro', init: 'Create Alignment' },
      canRender:      { is: 'ro', init: true },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Create alignment' },
      sequences:      { is: 'rw', init: null },
      dontAlign:      { is: 'rw', init: []   },
      htmlToRender:   { is: 'rw', init: '' },
      matrix_id:      { is: 'rw', init: '' }
    },
    after:  {
      initialize: function () {
        this.handlers().push( this.frame().on('state:displayed', function () {
          if (this._htmlToRender == '' ){
            var me = this;
            new Ajax.Request(this.route('render_alignment_seqs_project_molecular_sequences_path'), {
              method: 'post',
              parameters: { ids: Object.toJSON(this._sequences)},
              onSuccess: function (response){
                me.setHtmlToRender(response.responseJSON.html_to_render);
                $('seqs_for_alignment').innerHTML = me._htmlToRender;
                me.notifier().success('Alignment prepared.')
              },
              onFailure: function (response){me.notifier().error('Sorry, something went wrong.')}
            })
          }
          $('seqs_for_alignment').innerHTML = this._htmlToRender;
        }, this) );
      }
    },
    methods: {
      onClick: function (event) {
        var me = this
          , include_a = '<a class="include_seq"><img src="/images/plus.png" width="15" height="15" alt="do save" /></a>'
          , exclude_a = '<a class="remove_seq"><img src="/images/16-em-cross.png" alt="don\'t save" /></a>';
        Event.delegate({
          'input.saveButton': function () {
            var seqs = $('seqs_for_alignment').select('td.seq_td').map(function(td){if (td.visible()) return td.id.split('_').last();}).compact();
            me.notifier().working('Creating alignment...')
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/create_alignment', {
              method: 'post',
              parameters: { 'seqs[]': seqs,
                            'alignment[name]': $('alignment_name').value,
                            'alignment[description]': $('alignment_description').value,
                            'matrix_id': me._matrix_id
              },
              onSuccess:  function (response) {
                me.notifier().success('Successfully created alignment.  ')
                window.location = '/projects/' + params['project_id'] + '/molecular/alignments/' + response.responseJSON.alignment.evalJSON().alignment.id.toString()
                //return id of created alignment and display alignment
              },
              onFailure:  function (response) {me.notifier().error('Sorry, something went wrong.  ')},
              onComplete: function (response) {}
            })
          },
          'a.remove_seq': function (event){
            var seqId = event.element().up('tr').id.split('_')[1];
            this._dontAlign.push(seqId)
            this._dontAlign.each(function(id){
              if ($('td_' + id).visible()) $('td_' + id).toggle()
            })
            event.element().replace(include_a)
          },
          'a.include_seq': function (event){ 
            var seqId = event.element().up('tr').id.split('_')[1];
            if (!$('td_' + seqId).visible()) $('td_' + seqId).toggle()
            this.setDontAlign(this._dontAlign.without(seqId))
            event.element().replace(exclude_a)
          }
        }).call(this, event)

      }
    }
  })
})