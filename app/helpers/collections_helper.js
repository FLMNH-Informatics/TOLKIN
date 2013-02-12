Role('CollectionsHelper', {
  methods: {
    _typeStatuses: function () {
      return([
        [ '', 'none' ],
        [ 'Holotype', 'holotype' ],
        [ 'Isotype', 'isotype' ],
        [ 'Neotype', 'neotype' ],
        [ 'Lectotype', 'lectotype' ],
        [ 'Isolectotype', 'isolectotype' ],
        [ 'Syntype', 'syntype' ],
        [ 'Isosyntype', 'isosyntype' ],
        [ 'Paratype', 'paratype' ],
        [ 'Isoparatype', 'isoparatype' ],
        [ 'Isoneotype', 'isoneotype'],
        [ 'Non est Typus', 'non_est_typus' ],
        [ 'Type', 'type' ]
      ])
    }

//    catalogButtons: function (options) {
//      return options.inject('', function (acc, buttonOptions) {
//        return(acc
//          +(!buttonOptions.interactMode || buttonOptions.interactMode == this.interactMode() ?
//            '\
//            <div class="button active" value="//'+buttonOptions.value+'">\n\
//              <table>\n\
//                <tr>\n\
//                  <td>\n\
//                    <img src="/images///'+buttonOptions.img.src+'"'
//                    +(buttonOptions.img.size ?
//                      ' style="width:'
//                        +buttonOptions.img.size.split('x')[0]
//                        +'px; height:'
//                        +buttonOptions.img.size.split('x')[1]
//                        +'px"'
//                      : ''
//                    )
//                    +' />\n\
//                  </td>\n\
//                  <td>\n\
//                    <span>//'+buttonOptions.value+'</span>\n\
//                  </td>\n\
//                </tr>\n\
//              </table>\n\
//            </div>\n\
            //'
//            : ''
//          )
//
//        );
//      }, this);
//    },

//    collectionsCatalogButtons: function () {
//      return this.catalogButtons([
//        { value: 'Create', interactMode: 'edit', img: { src: 'addnew.gif', size: '14x14' } },
//        { value: 'Delete', interactMode: 'edit', img: { src: '16-em-cross.png' } },
//        { value: 'Export', interactMode:                      img: { src: 'report.png', size: '16x16' } }
//      ]);
//    }
  }
});
