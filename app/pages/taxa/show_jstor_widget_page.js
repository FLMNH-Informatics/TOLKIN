//= require <page>
//= require <html_loader>

JooseModule('Taxa', function (){
    JooseClass('ShowJstorWidgetPage', {
        isa: Page,
        has: {
            canRender: {is: 'ro', init: false},
            htmlLoader: {is: 'ro', init: function () {return $HtmlLoader({
                    pathname: 'show_jstor_widget_project_taxon_path'
                }, this) } },
            title: {is: 'ro', init: 'JSTOR Widget Results'},
            savable: {is: 'ro', init: false},
            records: { is: 'ro', lazy: true, init: function () { return($Records({
                    taxon: new Taxon({ id: this.context().params().id, context: this.frame().context()})
                }, this) ) } }
        },
        after:{
            onLoad: function (){
                $('JSTOR-PLANTS').innerHTML = this._rendered
            }
        },
        methods:{
            onClick: function (event){
                var taxon = this.record('taxon')
                    , me = this;
                Event.delegate({
                    '.back_to_taxon': function (event){
                        event.stop();
                        me.context().frame().loadPage('project_taxon_path', {id: taxon._id});
                    }
                }).bind(this)(event)
            }
        }
    })
})