//= require <templates/action_panel>

JooseModule('Ncbi.Seqs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      context: { is: 'ro', required: true, nullable: false },
      buttons: { is: 'ro', init: function () { return(
            [ { label: 'Import',
                img: { src: '/images/addnew.gif' }
              }
            ]
          )
      }}
    }
  })
});