Role('FormOptionsHelper', {
  methods: {
    select: function (object, method, choices) {
      return(
        '<select name="'+object.shortName()+'['+method+']">'+
        choices.collect(function (choice) {
          return(
            '<option value="'
            +choice[1] + '"'
            +(object.attributes()[method] == choice[1] ? ' selected="selected"' : '')
            +'>'
            +choice[0]
            +'</option>'
          );
        })+
        '</select>'
      )
    }
  }
});