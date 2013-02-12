//= require <page>
//= require <molecular/primer>
//= require <roles/polling>

//FIXME: needs to be updated
JooseModule('Molecular.Primers', function () {
  JooseClass('ShowPage',{
    isa: Page,
//    does: [ Polling ],
    has: {
      canRender:  { is: 'ro', init: false },
      htmlLoader: { is: 'ro', lazy: true, init: function () { return $HTMLLoader({ pathname: 'project_molecular_primer_path'}, this) }},
      title:      { is: 'ro', init: 'Primer : Show' },
      width:      { is: 'ro', init: 540  },
      height:     { is: 'ro', init: 425  },
      savable:    { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Update primer'},
//      templates:  { is: 'ro', lazy: true, init: function () { return $TSet([
//           'molecular/primers/_primer_details'
//      ], this)}},
      records:    { is: 'ro', lazy: true, init: function () { return($RSet({
          primer:
            new Molecular.Primer({
              id: this.context().params().id,
              context: this.frame().context()
            })
      }, this))}}
    },
    after: {
      initialize: function() {
        params['primer_id'] = params['id'];
//      },
//
//      load: function () {
//        var me = this;
//        this.context().interactMode().on('set', (function() {
//          this.poll({
//            on: function () { return me.frame().templates().get('molecular/primers/_primer_details') },
//            run: me.frame().render
//          });
//        }).bind(this.frame()));
      }
    },
    methods:{
      primer: function () {return this.records().get('primer') },
      onChange: function (event) {       //for toggling select new inputs
        var el = event.element();
        if ( el == $('primer_marker_id') || el == $('primer_purification_method_id') ){
          if(el.value == 'new'){
            if (!el.next().visible()) el.next().toggle()
          }else{
            if (el.next().visible() ) el.next().toggle()
          }
        }
      },
      onClick: function(event) {
              var me = this;
              Event.delegate({
                '.saveButton.active': function (event) {
                  var weight = $('primer_molecular_weight').value;
                  if (isNumber(weight) || weight == ''){
                    me.notifier().working('Updating primer...');
                    $$('form')[0].request({
                      onSuccess: function(response){
                        me.notifier().success('Primer updated.');
                        var primer = new Molecular.Primer({ context: me.context() });
                        primer.fire('update', { memo: { record: primer } });
                      },
                      onFailure: function(response){me.notifier().error('Something went wrong.')}
                    })
                  }else{me.notifier().warning('Molecular weight must be a number.')}
                }
              }).call(this,event)
      }
    }
  })
})

