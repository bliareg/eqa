// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);

function isSubscriptionAlreadyCreate(subscriptionName) {
  return App.cable.subscriptions.subscriptions.find(function(el) {
    return JSON.parse(el.identifier).channel == subscriptionName;
  });
}
