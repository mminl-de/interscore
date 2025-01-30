const socket = new WebSocket("ws://localhost:8080", "interscore")

socket.onopen = () => {
	console.log("TODO js client just connected to server!")
	socket.send("TODO hi server")
}

socket.onerror = (error) => {
	console.error("WebSocket Error: ", error)
}

socket.onmessage = (event) => {
	console.log("TODO got a message: ", event.data)
}

socket.onclose = () => {
	console.log("WebSocket connection closed!")
}

console.log("TODO: hi from scoreboard.js (this always runs)")
