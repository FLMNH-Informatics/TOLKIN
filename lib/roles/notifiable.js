/** section: Role
 *  mixin Notifiable
**/
Module('TOLJS.role', function() {
  Role('Notifiable', {
    requires: ['error','success','warning','working']
  })
});