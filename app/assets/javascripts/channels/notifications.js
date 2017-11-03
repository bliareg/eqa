function add_push_up_notifications_subscribe() {
  if (isSubscriptionAlreadyCreate('NotificationsChannel')) {
    return false;
  }

  App.notifications = App.cable.subscriptions.create("NotificationsChannel", {
    connected: function() {
      // Called when the subscription is ready for use on the server
    },

    disconnected: function() {
      // Called when the subscription has been terminated by the server
    },

    received: function(data) {
      $('.wrapper').append(data.message);
    }
  });
}

function remove_subscribe_push_up_notifications() {
  if (App.notifications) {
    App.notifications.unsubscribe();
  }
};

$(document).on('click', 'body', function (e){
  notifications = $('.notification.open')
  if( $(e.target).closest(".notification.open").length > 0 || notifications.length == 0) return;
  notifications.remove();
});