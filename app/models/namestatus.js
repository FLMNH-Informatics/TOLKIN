//= require <sync_record>

JooseClass('Namestatus', {
    isa: SyncRecord,
    methods: {
        //requestPath: function() {
        //return "/namestatuses"
        //}

        requestPath: function() {
            return "/namestatuses/" + this.id();
        }
    }
});
