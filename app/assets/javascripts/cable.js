// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

// only use actioncable on device and control pages
if ((window.location.pathname.indexOf("/devices/") === 0) || (window.location.pathname.indexOf("/control/") === 0)) {

  (function() {
    this.App || (this.App = {});

    App.cable = ActionCable.createConsumer();

  }).call(this);

}
