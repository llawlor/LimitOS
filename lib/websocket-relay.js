// Example:
// node websocket-relay

var WebSocket = require('ws');

// Websocket Server for video stream
var incoming_video_server = new WebSocket.Server({port: 8081, perMessageDeflate: false});

// Websocket Server for clients (browsers)
var socketServer = new WebSocket.Server({port: 8082, perMessageDeflate: false});

incoming_video_server.connectionCount = 0;

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
    console.log(data);
    // for each web browser client of the server
    socketServer.clients.forEach(function each(client) {
      // if the auth tokens match and the websocket is open
      if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
        console.log('sending data');
        // send the data
        client.send(data);
      }
    });
  });

});

// keep track of authentication tokens and connected browsers
socketServer.device_counts = [];

// when a web browser is connected
socketServer.on('connection', function(socket, upgradeReq) {

  // get the auth token
  var auth_token = upgradeReq.url.split('/video_to_clients/')[1];
  // add the auth token to the connection
  socket.auth_token = auth_token;

  // if the device doesn't exist
  if (socketServer.device_counts[socket.auth_token] === undefined) {
    // add the device count, where the device is identified by the auth_token
    socketServer.device_counts[socket.auth_token] = 1;
  // else there's already a count
  } else {
    // increment the count
    socketServer.device_counts[socket.auth_token] += 1;
  }

	console.log(
		'New WebSocket Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'(auth_token: ' + socket.auth_token + ', count: ' + socketServer.device_counts[socket.auth_token] + ')'
	);

  // when the browser is disconnected
	socket.on('close', function(code, message){
    // decrement the count
    socketServer.device_counts[socket.auth_token] -= 1;
    // output the result
		console.log('Disconnected WebSocket (auth_token: ' + socket.auth_token + ', count: ' + socketServer.device_counts[socket.auth_token] + ')');

    // if there are no more clients
    if (socketServer.device_counts[socket.auth_token] === 0) {
      // for each raspberry pi client
      incoming_video_server.clients.forEach(function each(client) {

        // if the auth tokens match and the websocket is open
        if ((client.auth_token === socket.auth_token) && (client.readyState === WebSocket.OPEN)) {
          // send the data
          client.send(JSON.stringify({ 'stop_video': socket.auth_token }));
          client.send(JSON.stringify({ 'stop_rpi_microphone': socket.auth_token }));
          console.log('disconnecting video: ' + socket.auth_token);
        }

      });
    }

	});

});

console.log('Listening for video stream on ws://127.0.0.1:8081');
console.log('Awaiting WebSocket connections on ws://127.0.0.1:8082');
