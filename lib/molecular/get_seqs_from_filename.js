function get_seqs_from_filename(page, id, type){
  if (id){
    var me = page
    params['id'] = id
    if (type == 'detailed'){
      new Ajax.Request('/projects/' + params['project_id'] + '/molecular/fasta_filename/'+ id.toString(),{
        method:         'get',
        requestHeaders: {Accept: 'application/json'},
        onSuccess: function (response){
          if ( response.responseJSON.ids.length != 0){
            me.notifier().working('Fetching sequences...')
            me.setSeqIds(response.responseJSON.ids)
            me.setFastaFilenameId(id)
            load_appropriate_seq_page(me, me._seqIds[0])
          }else{
            me.notifier().notify('Sorry, there are no longer sequences associated with that filename');
            me.frame().loadPage('show_from_fasta_project_molecular_sequences_path')
          }
        },
        onFailure: function (response){},
        onComplete:function (response){}
      })
    }else if (type == 'list'){
      me.notifier().working('Querying for filename...')
      me.frame().loadPage('project_molecular_fasta_filename_path', { id: id})
    }
  }
}

function load_appropriate_seq_page(page, seq_id){
  page.frame().loadPage('project_molecular_sequence_path', {id: seq_id})
  page.frame()._page.setSeqIds(page._seqIds)
  page.frame()._page.setFastaFilenameId(page._fastaFilenameId)
  page.frame()._page.setCurrentSeqId(seq_id)
  page.frame()._page.setSeqCount(page._seqIds.length)
}