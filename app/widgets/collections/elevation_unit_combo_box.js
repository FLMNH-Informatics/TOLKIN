//= require <templates/combo_box>

JooseModule('Collections', function () {
  JooseClass('ElevationUnitComboBox', {
    isa: Templates.ComboBox,
    has: {
      method: { is: 'ro', init: 'elevation_unit' },
      collectionURI: { is: 'ro', init: function () { return Route.forPathname('length_units_path') } },
      valueMethod: { is: 'ro', init: 'id' },
      textMethod: { is: 'ro', init: 'name' },
      searchMethod:  { is: 'ro', init: 'name' },
      options: { is: 'ro', init: function () { return { parameters: { select: 'id,name' } } }}
    }
  })
});