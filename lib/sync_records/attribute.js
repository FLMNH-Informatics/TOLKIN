//= require "condition"

JooseModule('SyncRecords', function () {
  JooseClass('Attribute', {
    has: {
      name: { is: 'ro', required: true, nullable: false }
    },
    methods: {
      eq: function (value) {
        return new SyncRecords.Condition({ subj: this.name(), obj: value.toString(), prop: 'eq' })
      },
      matches: function (value) {
        return new SyncRecords.Condition({ subj: this.name(), obj: value.toString(), prop: 'matches'})
      },
      ne: function (value) {
        return new SyncRecords.Condition({ subj: this.name(), obj: value.toString(), prop: 'ne' })
      },

      toString: function () {
        return this.name()
      }
    }
  })
});
