//= require <page>
//= require <html_loader>

JooseModule('Molecular.Markers', function () {
  JooseClass('DisplaySeqsPage', {
    isa: Page,
    has: {
      canRender:  {is: 'ro', init: true },
      height:     {is: 'ro', init: 500 },
      width:      {is: 'ro', init: 900 },
      title:      {is: 'ro', init: 'Sequences' },
      savable:    {is: 'ro', init: false},
      htmlLoader: {is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'display_seqs_project_molecular_marker_path'
      }, this)}}
    },
    methods:{
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.seq_show': function(event){
            var seqId = event.element().readAttribute('data-seq-id');
            me.frame().viewport().widget('window').loadPage('project_molecular_sequence_path', {id: seqId});
          }
        }).call(this,event)
      }
    }
  })
})