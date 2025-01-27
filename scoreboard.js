const socket = new WebSocket("ws://localhost:8080", "interscore")

socket.onmessage = (event) => {
	console.log("TODO got a new event")
	console.log(event)
}

socket.onopen = () => socket.send("TODO hi server")

console.log("TODO: hi from scoreboard.js (this always runs)")
