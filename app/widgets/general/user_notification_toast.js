//= require <widgets/templates/toast>

Module('General', function () {
  JooseClass('UserNotificationToast', {
    isa: Widgets.Templates.Toast
  })
});