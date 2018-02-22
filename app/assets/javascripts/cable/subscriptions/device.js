// only use actioncable on device pages
if (window.location.pathname.indexOf("/devices/") === 0) {
  App.cable.subscriptions.create({ channel: "DevicesChannel" });
}
