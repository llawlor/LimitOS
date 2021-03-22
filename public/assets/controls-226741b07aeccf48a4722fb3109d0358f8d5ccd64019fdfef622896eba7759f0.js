function sendServoMessage(e){App.messaging.send_message(e)}function sendSynchronization(e){var o={synchronization_id:e};App.messaging.send_message(o)}function sendOppositeSynchronization(e){var o={synchronization_id:e,opposite:"true"};App.messaging.send_message(o)}function stopBrowserMicrophone(){media_recorder.stop()}function startBrowserMicrophone(){(microphone_websocket=new WebSocket(audio_input_url)).binaryType="arraybuffer",setTimeout(function(){navigator.mediaDevices.getUserMedia({audio:!0,video:!1}).then(handleMicrophoneSuccess)},500)}function startVideo(){video_active=!0,$("#video_start").addClass("hidden"),$("#video_canvas").removeClass("hidden");var e={command:"start_video"};App.messaging.send_message(e),video_player=new JSMpeg.Player(video_server_url,{canvas:$("#video_canvas")[0]}),$("#video_stop").removeClass("hidden"),$("#video_embed_button").removeClass("hidden")}function stopVideo(){video_active=!1,$("#video_stop").addClass("hidden"),$("#video_embed_button").addClass("hidden"),$("#embed_code_div").addClass("hidden"),$("#video_canvas").addClass("hidden"),video_player.destroy(),$("#video_start").removeClass("hidden")}function audioDataHandler(e){audio_queue=audio_queue===undefined?e:appendArrayBuffers(audio_queue,e),attachQueuedAudio()}function attachQueuedAudio(){source_buffer.updating||(source_buffer.appendBuffer(audio_queue),audio_queue=undefined)}function appendArrayBuffers(e,o){var n=new Uint8Array(e.byteLength+o.byteLength);return n.set(new Uint8Array(e),0),n.set(new Uint8Array(o),e.byteLength),n.buffer}function sendStartRpiMicrophone(){var e={command:"start_rpi_microphone"};App.messaging.send_message(e)}function startBrowserSpeakers(){if(audio_context===undefined){audio_context=new AudioContext;var e=document.getElementById("audio_element");e.playbackRate=1.05,source_node=audio_context.createMediaElementSource(e),(media_source=new MediaSource).addEventListener("sourceopen",function(){addSourceBuffer()}),e.src=URL.createObjectURL(media_source),source_node.connect(audio_context.destination),(audio_websocket=new WebSocket(audio_output_url)).binaryType="arraybuffer",audio_websocket.onmessage=function(e){audioDataHandler(e.data)}}document.getElementById("audio_element").play()}function addSourceBuffer(){source_buffer===undefined&&(source_buffer=media_source.addSourceBuffer('audio/webm;codecs="opus"')).addEventListener("updateend",function(){audio_queue!==undefined&&attachQueuedAudio()})}function stopBrowserSpeakers(){audio_websocket&&audio_websocket.close(),$("#audio_element")[0].src=undefined,$("#audio_element").replaceWith($("#audio_element").clone()),media_source=undefined,source_node=undefined,source_buffer=undefined,audio_websocket=undefined,audio_queue=undefined,audio_context=undefined}function stopRpiMicrophone(){var e={command:"stop_rpi_microphone"};App.messaging.send_message(e),resetBrowserSpeakers()}function resetBrowserSpeakers(){stopBrowserSpeakers(),setTimeout(function(){startBrowserSpeakers()},1e3)}function stopRpiSpeakers(){var e={command:"stop_rpi_speakers"};App.messaging.send_message(e)}function startRpiSpeakers(){var e={command:"start_rpi_speakers"};App.messaging.send_message(e)}function activityDetected(){clearTimeout(video_timeout),video_timeout=setTimeout(function(){stopVideo()},6e5)}var source_buffer,audio_queue,audio_context,media_source,audio_websocket,source_node,microphone_websocket,media_recorder,start_transmission_time=0,video_player=null,video_timeout=null,video_active=!1;$(document).ready(function(){$("#device-off").on("click",function(){if(confirm("Are you sure you want to shut down?")){var e={command:"shutdown"};App.messaging.send_message(e)}}),$("body").on("mousemove mousedown touchstart touchmove",function(){!0===video_active&&activityDetected()}),$("#video_start").on("click",function(){startVideo()}),$("#video_stop").on("click",function(){stopVideo()}),$("#start_browser_speakers").on("click",function(){startBrowserSpeakers()}),$("#stop_browser_speakers").on("click",function(){}),$("#start_rpi_microphone").on("click",function(){sendStartRpiMicrophone()}),$("#stop_rpi_microphone").on("click",function(){stopRpiMicrophone()}),$("#start_rpi_speakers").on("click",function(){startRpiSpeakers()}),$("#stop_rpi_speakers").on("click",function(){stopRpiSpeakers()}),$("#start_browser_microphone").on("click",function(){startBrowserMicrophone()}),$("#stop_browser_microphone").on("click",function(){stopBrowserMicrophone()}),$("#video_embed_button").on("click",function(){$("#embed_code_div").removeClass("hidden"),$(this).addClass("hidden")}),$(".digital_submit").on("click",function(){$(".pin_"+$(this).data("pin")+"_buttons").removeClass("active"),$(".pin_"+$(this).data("pin")+"_buttons").blur();var e={i2c_address:device_i2c_address,pin:$(this).data("pin"),digital:$(this).data("digital")};App.messaging.send_message(e)}),$(".execute-synchronization").on("click",function(){var e={synchronization_id:$(this).data("id")};App.messaging.send_message(e)}),App.messaging=App.cable.subscriptions.create({channel:"DevicesChannel",id:device_id,auth_token:device_auth_token},{received:function(e){logData(e)},send_message:function(e){start_transmission_time=(new Date).getTime(),this.perform("receive",e)}})});const handleMicrophoneSuccess=function(e){(media_recorder=new MediaRecorder(e,{mimeType:"audio/webm"})).addEventListener("dataavailable",function(e){e.data.size>0&&microphone_websocket.send(e.data)}),media_recorder.start(200)};