//= requires "../type/savvy_parent"

Module('TOLJS.role', function() {
  Role('ParentDependent', {
    has: {
      parent: { is: 'ro', isa: TOLJS.role.SavvyParent, required: true, nullable: false}
    }
  })
})