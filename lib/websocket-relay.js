// Example:
// node websocket-relay

var WebSocket = require('ws');

// websocket server for video stream
var incoming_video_server = new WebSocket.Server({port: 8081, perMessageDeflate: false});
// websocket server for video clients (browsers)
var outgoing_video_server = new WebSocket.Server({port: 8082, perMessageDeflate: false});

// websocket server for audio stream
var incoming_audio_server = new WebSocket.Server({port: 8083, perMessageDeflate: false});
// websocket server for audio clients (browsers)
var outgoing_audio_server = new WebSocket.Server({port: 8084, perMessageDeflate: false});

// set initial connection counts
incoming_video_server.connectionCount = 0;
incoming_audio_server.connectionCount = 0;
// keep track of authentication tokens and connected browsers
outgoing_video_server.device_counts = [];
outgoing_audio_server.device_counts = [];

// when a raspberry pi is connected to send video
incoming_video_server.on('connection', function(socket, upgradeReq) {

  // get the auth token
  var auth_token = upgradeReq.url.split('/video_from_devices/')[1];
  // add the auth token to the connection
  socket.auth_token = auth_token;

	incoming_video_server.connectionCount++;
	console.log(
		'New Incoming Video Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'('+incoming_video_server.connectionCount+' total)'
	);

	socket.on('close', function(code, message){
		incoming_video_server.connectionCount--;
		console.log('Disconnected incoming video ('+incoming_video_server.connectionCount+' total)');
	});

  // when data is received (streaming video)
  socket.on('message', function(data) {
    // for each web browser client of the server
    outgoing_video_server.clients.forEach(function each(client) {
      // if the auth tokens match and the websocket is open
      if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
        // send the data
        client.send(data);
      }
    });
  });

});

// when an incoming audio connection arrives
incoming_audio_server.on('connection', function(socket, upgradeReq) {

  // get the auth token
  var auth_token = upgradeReq.url.split('/audio_input/')[1];
  // add the auth token to the connection
  socket.auth_token = auth_token;

	incoming_audio_server.connectionCount++;
	console.log(
		'New Incoming Audio Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'('+incoming_audio_server.connectionCount+' total)'
	);

	socket.on('close', function(code, message){
		incoming_audio_server.connectionCount--;
		console.log('Disconnected incoming audio ('+incoming_audio_server.connectionCount+' total)');
	});

  // when data is received (streaming audio)
  socket.on('message', function(data) {
    //console.log(data);
    // for each outgoing audio connection
    outgoing_audio_server.clients.forEach(function each(client) {
      // if the auth tokens match and the websocket is open
      if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
        //console.log('sending data');
        // send the data
        client.send(data);
      }
    });
  });

});

// when a web browser is connected to receive video
outgoing_video_server.on('connection', function(socket, upgradeReq) {

  // get the auth token
  var auth_token = upgradeReq.url.split('/video_to_clients/')[1];
  // add the auth token to the connection
  socket.auth_token = auth_token;

  // if the device doesn't exist
  if (outgoing_video_server.device_counts[socket.auth_token] === undefined) {
    // add the device count, where the device is identified by the auth_token
    outgoing_video_server.device_counts[socket.auth_token] = 1;
  // else there's already a count
  } else {
    // increment the count
    outgoing_video_server.device_counts[socket.auth_token] += 1;
  }

	console.log(
		'New Video WebSocket Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'(auth_token: ' + socket.auth_token + ', count: ' + outgoing_video_server.device_counts[socket.auth_token] + ')'
	);

  // when the browser is disconnected
	socket.on('close', function(code, message){
    // decrement the count
    outgoing_video_server.device_counts[socket.auth_token] -= 1;
    // output the result
		console.log('Disconnected WebSocket (auth_token: ' + socket.auth_token + ', count: ' + outgoing_video_server.device_counts[socket.auth_token] + ')');

    // if there are no more clients
    if (outgoing_video_server.device_counts[socket.auth_token] === 0) {
      // for each raspberry pi client
      incoming_video_server.clients.forEach(function each(client) {

        // if the auth tokens match and the websocket is open
        if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
          // send the data
          client.send(JSON.stringify({ 'stop_video': socket.auth_token }));
          console.log('disconnecting video: ' + socket.auth_token);
        }

      });
    }

	});

});

// when a connection is made to receive audio
outgoing_audio_server.on('connection', function(socket, upgradeReq) {

  // get the auth token
  var auth_token = upgradeReq.url.split('/audio_output/')[1];
  // add the auth token to the connection
  socket.auth_token = auth_token;

  // if the device doesn't exist
  if (outgoing_audio_server.device_counts[socket.auth_token] === undefined) {
    // add the device count, where the device is identified by the auth_token
    outgoing_audio_server.device_counts[socket.auth_token] = 1;
  // else there's already a count
  } else {
    // increment the count
    outgoing_audio_server.device_counts[socket.auth_token] += 1;
  }

	console.log(
		'New Audio WebSocket Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'(auth_token: ' + socket.auth_token + ', count: ' + outgoing_audio_server.device_counts[socket.auth_token] + ')'
	);

  // when the browser is disconnected
	socket.on('close', function(code, message){
    // decrement the count
    outgoing_audio_server.device_counts[socket.auth_token] -= 1;
    // output the result
		console.log('Disconnected WebSocket (auth_token: ' + socket.auth_token + ', count: ' + outgoing_audio_server.device_counts[socket.auth_token] + ')');

    // if there are no more clients
    if (outgoing_audio_server.device_counts[socket.auth_token] === 0) {
      // for each raspberry pi client
      incoming_audio_server.clients.forEach(function each(client) {

        // if the auth tokens match and the websocket is open
        if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
          // send the data
          client.send(JSON.stringify({ 'stop_rpi_microphone': socket.auth_token }));
          console.log('disconnecting audio: ' + socket.auth_token);
        }

      });
    }

	});

});

console.log('Listening for video stream on ws://127.0.0.1:8081');
console.log('Awaiting WebSocket connections on ws://127.0.0.1:8082');
console.log('Listening for audio stream on ws://127.0.0.1:8083');
console.log('Awaiting WebSocket connections on ws://127.0.0.1:8084');
