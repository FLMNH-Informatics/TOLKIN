//= require <page>
//= require <html_loader>

JooseModule('Molecular.Markers', function(){
  JooseClass('DisplayMatricesPage', {
    isa: Page,
    has: {
      canRender:  {is: 'ro', init: true },
      height:     {is: 'ro', init: 500 },
      width:      {is: 'ro', init: 800 },
      title:      {is: 'ro', init: 'Matrices' },
      savable:    {is: 'ro', init: false},
      htmlLoader: {is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'display_matrices_project_molecular_marker_path'
      }, this)}}
    }
  })
})