// keep track of the start transmission time
var start_transmission_time = 0;
// keep track of the video player
var video_player = null;
// keep track of the video timeout
var video_timeout = null;
// keep track of whether the video is currently playing
var video_active = false;

// when the document is ready
$(document).ready(function() {

  // when user activity is detected
  $('body').on('mousemove mousedown touchstart touchmove', function() {
    // only detect activity if video has been played
    if (video_active === true) { activityDetected(); }
  });

  // when the start video button is clicked
  $('#video_start').on('click', function() {
    // start the video
    startVideo();
  });

  // when the stop video button is clicked
  $('#video_stop').on('click', function() {
    // stop the video
    stopVideo();
  });

});

// new user activity is detected
function activityDetected() {
  // clear the current timeout
  clearTimeout(video_timeout);

  // set new timeout for 10 minutes
  video_timeout = setTimeout(function() {
    // stop video
    stopVideo();
  }, 600000);
}
