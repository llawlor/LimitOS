// Example:
// node websocket-relay

var WebSocket = require('ws');

// Websocket Server for video stream
var incoming_video_server = new WebSocket.Server({port: 8081, perMessageDeflate: false});

// Websocket Server for clients (browsers)
var socketServer = new WebSocket.Server({port: 8082, perMessageDeflate: false});

incoming_video_server.connectionCount = 0;

incoming_video_server.on('connection', function(socket, upgradeReq) {
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
    socketServer.clients.forEach(function each(client) {
      // if the websocket is open
      if (client.readyState === WebSocket.OPEN) {
        // send the data
        client.send(data);
      }
    });
  });
});

socketServer.connectionCount = 0;

socketServer.on('connection', function(socket, upgradeReq) {
	socketServer.connectionCount++;
	console.log(
		'New WebSocket Connection: ',
		(upgradeReq || socket.upgradeReq).socket.remoteAddress,
		(upgradeReq || socket.upgradeReq).headers['user-agent'],
		'('+socketServer.connectionCount+' total)'
	);
	socket.on('close', function(code, message){
		socketServer.connectionCount--;
		console.log('Disconnected WebSocket ('+socketServer.connectionCount+' total)');
	});
});

console.log('Listening for video stream on ws://127.0.0.1:8082');
console.log('Awaiting WebSocket connections on ws://127.0.0.1:8082');
