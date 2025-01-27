const socket = new WebSocket("ws://localhost:6969", "callback_interscore")

socket.onmessage = () => {
	console.log("TODO just got a new event, yippie")
}

socket.onopen = () => socket.send("TODO hi server")

console.log("TODO: hi from scoreboard.js (this always runs)")
