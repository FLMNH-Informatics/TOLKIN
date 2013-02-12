//= require <page>

JooseModule('Nexus_Dataset', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRendeR: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Upload Nexus Dataset' },
      width: { is: 'ro', init: 500 }

    }
  })
})