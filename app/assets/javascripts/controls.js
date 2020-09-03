// keep track of the start transmission time
var start_transmission_time = 0;
// keep track of the video player
var video_player = null;
// keep track of the video timeout
var video_timeout = null;
// keep track of whether the video is currently playing
var video_active = false;
// keep track of the source buffer (audio chunk interface)
var source_buffer;
// holds the data from multiple ArrayBuffers (websocket mp3 audio data)
var audio_queue;
// holds the audio context; if intially undefined, sets up the audio listeners when 'start audio' is clicked
var audio_context;

// when the document is ready
$(document).ready(function() {

  // when the power off button is clicked
  $('#device-off').on('click', function() {
    // if confirmed
    if (confirm('Are you sure you want to shut down?')) {
      // create the message
      var message = { command: 'shutdown' };
      // send the message to shut down
      App.messaging.send_message(message);
    }
  });

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

  // when the start audio button is clicked
  $('#audio_start').on('click', function() {
    // start the audio
    startAudio();
  });

  // when the stop audio button is clicked
  $('#audio_stop').on('click', function() {
    // stop the audio
    stopAudio();
  });

  // when the stop listening button is clicked
  $('#listening_stop').on('click', function() {
    // stop listening to audio
    stopListening();
  });

  // when the embed code button is clicked
  $('#video_embed_button').on('click', function() {
    // show the embed code
    $('#embed_code_div').removeClass('hidden');
    // hide the button
    $(this).addClass('hidden');
  });

  // when the digital on/off button is clicked
  $('.digital_submit').on('click', function() {
    // remove active class
    $('.pin_' + $(this).data('pin') + '_buttons').removeClass('active');
    // blur the button to make it unfocused
    $('.pin_' + $(this).data('pin') + '_buttons').blur();
    // create the message
    var message = { i2c_address: device_i2c_address, pin: $(this).data('pin'), digital: $(this).data('digital') };
    // send the message
    App.messaging.send_message(message);
  });

  // when an 'execute synchronization' button is clicked
  $('.execute-synchronization').on('click', function() {
    // create the message
    var message = { synchronization_id: $(this).data('id') };
    // send the message
    App.messaging.send_message(message);
  });

  // create the subscription
  App.messaging = App.cable.subscriptions.create(
    {
      channel: 'DevicesChannel',
      id: device_id,
      auth_token: device_auth_token
    },
    {

      // when data is received
      received: function(data) {
        // log the data
        logData(data);
      },

      // function to send a message
      send_message: function(message) {
        // mark the start time
        start_transmission_time = (new Date).getTime();

        // perform the "receive" action in app/channels/devices_channel.rb
        this.perform('receive', message);
      }

    }
  );

});

// send servo position
function sendServoMessage(message) {
  // send the message
  App.messaging.send_message(message);
}

// send a synchronization message by id
function sendSynchronization(synchronization_id) {
  // create the message
  var message = { synchronization_id: synchronization_id };
  // send the message
  App.messaging.send_message(message);
}

// send an opposite synchronization message by id
function sendOppositeSynchronization(synchronization_id) {
  // create the message
  var message = { synchronization_id: synchronization_id, opposite: 'true' };
  // send the message
  App.messaging.send_message(message);
}

// start the video
function startVideo() {
  // mark the video as started
  video_active = true;
  // hide the button
  $('#video_start').addClass('hidden');
  // show the canvas
  $('#video_canvas').removeClass('hidden');
  // create the message
  var message = { command: 'start_video' };
  // send the message to start the video
  App.messaging.send_message(message);
  // load the video
  video_player = new JSMpeg.Player(video_server_url, {canvas: $('#video_canvas')[0]});
  // show the stop button
  $('#video_stop').removeClass('hidden');
  // show the embed button
  $('#video_embed_button').removeClass('hidden');
}

// stop the video
function stopVideo() {
  // mark the video as stopped
  video_active = false;
  // hide the video stop button
  $('#video_stop').addClass('hidden');
  // hide the embed button
  $('#video_embed_button').addClass('hidden');
  // hide the embed code
  $('#embed_code_div').addClass('hidden');
  // hide the canvas
  $('#video_canvas').addClass('hidden');
  // disconnect the video
  video_player.destroy();
  // show the start button
  $('#video_start').removeClass('hidden');
}

// handle the audio data
function audioDataHandler(audio_data) {
  // if the audio queue is empty
  if (audio_queue === undefined) {
    // set it to the audio data
    audio_queue = audio_data;
  // else queued data exists
  } else {
    // append the audio data
    audio_queue = appendArrayBuffers(audio_queue, audio_data);
  }

  // add queued audio data to the audio element
  attachQueuedAudio();
}

// add queued audio data to the audio element
function attachQueuedAudio() {
  // if the source isn't being updated
  if (!source_buffer.updating) {
    // add the queued audio data
    source_buffer.appendBuffer(audio_queue);
    // reset the audio queue variable
    audio_queue = undefined;
  }
}

// add two array buffers together
function appendArrayBuffers(buffer1, buffer2) {
  // empty array with the proper byte length
  var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
  // add the first buffer
  tmp.set(new Uint8Array(buffer1), 0);
  // add the second buffer at the appropriate position
  tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
  // return the concatenated array buffers
  return tmp.buffer;
};

// send the websocket message to start audio
function sendStartAudioCommand() {
  // create the message to the limitos server
  var message = { command: 'start_audio' };
  // send the message to start the audio
  App.messaging.send_message(message);
}

// start the audio
function startAudio() {
  // if this is the first time connecting the audio context
  if (audio_context === undefined) {
    // create an audio context
    audio_context = new AudioContext();
    // get the audio element
    var audio_element = document.getElementById('audio_element');
    // attach the audio element as the source of the audio context
    var source_node = audio_context.createMediaElementSource(audio_element);
    // create a media source
    var media_source = new MediaSource();

    // add an event listener for when the source is opened
    media_source.addEventListener('sourceopen', function() {

      // set the source buffer for webm audio
      source_buffer = media_source.addSourceBuffer('audio/webm;codecs="opus"');
      // create the message to the limitos server
      sendStartAudioCommand();

      // listen for updateened events
      source_buffer.addEventListener('updateend', function() {
        // if the audio queue exists
        if (audio_queue !== undefined) {
          // attach the queued audio
          attachQueuedAudio();
        }
      });

    });

    // set the src attribute, which will also trigger the 'sourceopen' event on the media source
    audio_element.src = URL.createObjectURL(media_source);
    // prepare output to speakers
    source_node.connect(audio_context.destination);

    // audio server websocket
    var audio_websocket = new WebSocket(video_server_url);
    // set the data type
    audio_websocket.binaryType = "arraybuffer";
    // when a message is received
    audio_websocket.onmessage = function(message) {
      // push the audio data on to the queue
      audioDataHandler(message.data);
    }
  // else setup has already occurred
  } else {
    // create the message to the limitos server
    sendStartAudioCommand();
  }

  // start playing audio immediately
  document.getElementById('audio_element').play();
}

// stop the audio
function stopAudio() {
  // create the message
  var message = { command: 'stop_audio' };
  // send the message to start the audio
  App.messaging.send_message(message);
}

// stop listening to audio
function stopListening() {
  // create the message
  var message = { command: 'stop_listening' };
  // send the message to start the audio
  App.messaging.send_message(message);
}

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
