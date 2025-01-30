let socket = new WebSocket("ws://localhost:8080", "interscore")
socket.binaryType = "arraybuffer"

socket.onopen = () => {
	console.log("Connected to WebSocket server!")
	socket.send("Send data")
}

socket.onmessage = (event) => {
	// TODO
	if (!(event.data instanceof ArrayBuffer))
		console.error("Sent data is not in proper binary format!")

	let buffer = event.data
	let view = new DataView(buffer)
}

socket.onerror = (error) => {
	console.error("WebSocket Error: ", error)
}

socket.onclose = () => {
	console.log("WebSocket connection closed!")
}

console.log("TODO: hi from scoreboard.js (this always runs)")
