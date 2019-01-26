// only use actioncable on device and control pages
if ((window.location.pathname.indexOf("/devices/") === 0) || (window.location.pathname.indexOf("/control/") === 0) || (window.location.pathname.indexOf("/drive/") === 0)) {
  App.cable.subscriptions.create({ channel: "DevicesChannel" });
}
