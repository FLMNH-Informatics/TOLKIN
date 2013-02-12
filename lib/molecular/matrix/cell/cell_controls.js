JooseRole('CellControls', {
  after: {
    onLoad: function(){
      var owners = $$('span.owner').collect( function (ele) { return ele.innerHTML });
      $('genbank_gene_field').value = owners[1];
      $('genbank_org_field').value = owners[0];
      $$('input[name="search[markers_fulltext]"]')[0].value = owners[1];
      this.widgets().get('catalog').widgets().get('filterSet').setCollectionOptions($$('input[name="search[markers_fulltext]"]')[0].up('form').serialize({hash:true,submit:false}))
      eSearch($('genbank_term').value.strip(), this, 'no');
      toggleGenbankInputs();
    }
  },
  methods: {
    onClick: function (event) {
      if (this.is('loaded')) {
        var owners = $$('span.owner').collect( function (ele) { return ele.innerHTML });
        if (this.iMode()._value == 'edit'){
          $$('input.saveButton').first().writeAttribute('tool', 'update');
          $$('input.button_img').first().writeAttribute('tool', 'add');
        }
      }
      if (event.element().hasAttribute('tool')) {
        this.useTools(event.element(), event.element().readAttribute('tool'), event);
      }
      if (event.element().hasClassName('display_sequence')){
        this.frame().loadPage('project_molecular_sequence_path', { id: event.element().up('tr').dataset.seqId })
      }
    },
    request: function (form) {
      var me = this,
          tolkinSeqs = $('sequencelisttable').select('tr[data-seq-id]').length > 0 ? $('sequencelisttable').select('tr[data-seq-id]').map(function(el){return el.dataset.seqId}).join(',') : ''
        , gbSeqs
        , gbSeqs_index = $('sequencelisttable').select('tr[gb_index_id]').length > 0 ? $('sequencelisttable').select('tr[gb_index_id]').map(function(el){return parseInt(el.readAttribute('gb_index_id'))}) : '';
      if (typeof gbSeqs_index != "string"){
        gbSeqs = gbSeqs_index.map(function(id){return Object.toJSON(me._sequences[id])});
      }else{gbSeqs = '';}
      this.notifier().working('Updating Cell...');
      form.request({
        requestHeaders: ["Accept", "application/json"],
        parameters: {'tolkin_seqs': tolkinSeqs, 'gb_seqs[]': gbSeqs},
        onSuccess: function (response) {
          if (response.responseJSON.error){ me.notifier().error(response.responseJSON.message)
          }else{
            var cellHTML = $(response.responseJSON.htmlid);
            cellHTML.replace(response.responseJSON.htmlcell);
            me.notifier().success('Cell Updated');
            me.frame().close();
          }
        }
      })
    },
    useTools: function (element, tool, event) {
      var seqsCatalog       = $('list_items_form')
        , seqsAssigned      = $('cell_sequences_list')
        , removeSeqsInput   = $('seq_removed')
        , primaryInput      = $('seq_primary')
        , me                = this;

      if (['beginning','end','step_back','step_forward'].indexOf(tool) != -1) {
          if (!element.hasClassName('inactive')){
            changeResults(this, tool);
          }
        }

      switch (tool) {
        case 'primary':
          checkPrimary();
        break
        case 'remove':
          removeSequences();
        break
        case 'add':
          addSequences();
        break
        case 'update':
          this.request(me.frame().element().down('form'));
        break
        case 'esearch':
          me.setSeqStart(0);
          eSearch($('genbank_term').value.strip(), me);
        break
        case 'seq_check':
          if (event.shiftKey == true){ me.shiftCheck(event).each(function (chk) { toggleSeq(me, chk) }) }
          toggleSeq(me, element);
         break;
        case 'toggle_search':
          toggleSearch(element);
        break
        case 'unselect_all_seqs':
            unselectAllSeqs(me);
        break;
        case 'add_genbank':
          $('cell_sequences_list').innerHTML = $('cell_sequences_list').innerHTML + displayGenbankSeqs(me);
        break
        case 'toggle_genbank_inputs':
          toggleGenbankInputs();
        break
      }
      function checkPrimary(){
        var checked = seqsAssigned.getElementsBySelector('input:checkbox:checked');
        if (checked.length > 1) {alert('You can only mark one sequence as primary.  Only select one.')}
        else if (checked.length == 1){ setPrimary(checked.first().up().up())}
      }
      function setPrimary(seqTr) {
        var tds = seqsAssigned.getElementsBySelector('td');
        var isPrimary = tds.any(function(td){return td.innerHTML == 'primary'});
        if (seqsAssigned.getElementsBySelector('tr').first()){
          var td = isPrimary ?
            tds.detect(function(td){ return td.innerHTML == 'primary' })
            : seqsAssigned.getElementsBySelector('tr').first().getElementsBySelector('td').last();
          function getPrimary(){
            if (isPrimary){ return [true, td]; } else { return [false]; }
          }
          var results = getPrimary()
          if (!results[0]){
            td.innerHTML = 'primary';
            primaryInput.value = td.up().dataset.seqId
          }else if (results[0] && seqTr){
            results[1].innerHTML = '';
            primaryInput.value = seqTr.dataset.seqId;
            seqTr.down().next(2).innerHTML = 'primary';
          }
        }
      }
      function addSequences () {
        var checked = seqsCatalog.getElementsBySelector('input:checkbox:checked');
        var Seq = Class.create({
          initialize: function(seqID, organism){
            this.seqID = seqID;
            this.organism = organism; },
          toRow: function(){
            var classname = seqsAssigned.childElements().last() ?
              (seqsAssigned.childElements().last().hasClassName('body-odd') ? "body-even" : "body-odd")
              : "body-odd";
            return "<tr class='" + classname + "' id='tr_sequence_"+ this.seqID +"' data-seq-id='" + this.seqID + "'>" +
              "<td class='b'><input type='checkbox' id='sequence_#"+ this.seqID +"' name='cell_sequences[]' value='"+ this.seqID +"'></td>" +
              "<td class='b'><a target='_blank' href='/projects/" + params.project_id + "/molecular/sequences/" + this.seqID + "'><img src='/images/icon-zoom-14-smudged.gif' alt='[?]'></a></td>" +
              "<td class='b'>" + this.organism + "</td><td class=''></td></tr>"; }})
        checked.each (function(chk){
          var seqID = chk.readAttribute('value');
          var organism = chk.up().up().next().down().innerHTML;
          var seq = new Seq(seqID, organism);
          if (seqsAssigned.getElementsBySelector('input:checkbox').all(function(ele){ return ele.value != seqID })){
            seqsAssigned.insert({bottom: seq.toRow()});
          }
        })
        setPrimary();
      }
      function removeSequences () {
        var remove = (removeSeqsInput.value == '' ) ? [] : [removeSeqsInput.value];
        var checked = seqsAssigned.getElementsBySelector('input:checkbox:checked').collect(function (chkd) { return chkd.value });
        checked.each (function (val) {
          remove.push($('tr_sequence_' + val ).remove().dataset.seqId);
        })
        removeSeqsInput.value = remove.join();
        setPrimary();
      }
    }
  }
})