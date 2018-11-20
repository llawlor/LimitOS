// Example:
// node websocket-relay

var WebSocket = require('ws');

// Websocket Server
var socketServer = new WebSocket.Server({port: 8082, perMessageDeflate: false});

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
  // when data is received (streaming video)
  socket.on('message', function(data) {
    // for each client
    socketServer.clients.forEach(function each(client) {
      // if the websocket is open
      if (client.readyState === WebSocket.OPEN) {
        // send the data
        client.send(data);
      }
    });
  });
});

console.log('Awaiting WebSocket connections on ws://127.0.0.1:8082');
