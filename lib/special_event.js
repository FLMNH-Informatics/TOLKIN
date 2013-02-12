//changed name to CustomEventt because of namespace conflict in Firefox6 with CustomEvent in yahoo/color/yui library
JooseClass('SpecialEvent', {
  has: {
    type: { is: 'ro', required: true, nullable: false },
    from: { is: 'ro', required: true, nullable: false },
    memo: { is: 'ro' }
  }
});
