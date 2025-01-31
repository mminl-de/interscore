let socket = new WebSocket("ws://localhost:8080", "interscore")
socket.binaryType = "arraybuffer"

let scoreboard_team_1 = document.querySelector(".scoreboard > .team-1")!
let scoreboard_team_2 = document.querySelector(".scoreboard > .team-2")!
let scoreboard_score_1 = document.querySelector(".scoreboard > .score-1")!
let scoreboard_score_2 = document.querySelector(".scoreboard > .score-2")!

let game_plan_team_1 = document.querySelector(".game-plan > .team-1")!
let game_plan_team_2 = document.querySelector(".game-plan > .team-2")!
let game_plan_score_1 = document.querySelector(".game-plan > .score-1")!
let game_plan_score_2 = document.querySelector(".game-plan > .score-2")!

let card_graphic = document.querySelector(".card-graphic")! as HTMLElement
let card_receiver = document.querySelector(".card-receiver")!
let card_message = document.querySelector(".card-message")!

const BUFFER_LEN = 100

function write_scoreboard(view: DataView) {
	console.log("Writing data to scoreboard:\n", view)

	let offset = 1
	let team_1: String = ""
	let team_2: String = ""
	for (let i = 0; i < BUFFER_LEN; ++i) {
		team_1 += String.fromCharCode(view.getUint8(offset))
		team_2 += String.fromCharCode(view.getUint8(offset + BUFFER_LEN))
		++offset
	}
	scoreboard_team_1.innerHTML = team_1.toString()
	scoreboard_team_2.innerHTML = team_2.toString()

	scoreboard_score_1.innerHTML = view.getUint8(1 + 2 * BUFFER_LEN).toString()
	scoreboard_score_2.innerHTML = view.getUint8(1 + 2 * BUFFER_LEN + 1).toString()

	// TODO
	// let is_halftime = view.getUint8(202)
}

function write_game_plan(view: DataView) {
	let offset = 1
	const games_n = view.getUint8(offset)
	++offset

	for (let game = 0; game < games_n; ++game) {
		let team_1: String = ""
		let team_2: String = ""
		for (let name_char = 0; name_char < BUFFER_LEN; ++name_char) {
			team_1 += String.fromCharCode(view.getUint8(offset))
			team_2 += String.fromCharCode(view.getUint8(offset + games_n * BUFFER_LEN))
			++offset
		}
		game_plan_team_1.innerHTML = team_1.toString()
		game_plan_team_2.innerHTML = team_2.toString()
		++offset
	}
}

function write_card(view: DataView) {
	let offset = 1
	let receiver: String = ""
	for (let name = 0; name < BUFFER_LEN; ++name) {
		receiver += String.fromCharCode(view.getUint8(offset))
		++offset
	}
	card_receiver.innerHTML = receiver.toString()

	const is_red = view.getUint8(offset)

	if (is_red === 1) {
		card_graphic.style.backgroundColor = "#ff0000"
		card_message.innerHTML = "bekommt eine rote Karte"
	} else {
		card_graphic.style.backgroundColor = "#ffff00"
		card_message.innerHTML = "bekommt eine gelbe Karte"
	}
}

socket.onopen = () => {
	console.log("Connected to WebSocket server!")
}

socket.onmessage = (event: MessageEvent) => {
	// TODO
	if (!(event.data instanceof ArrayBuffer))
		console.error("Sent data is not in proper binary format!")
	console.log("TODO about to receive data")

	let buffer = event.data
	let view = new DataView(buffer)

	const mode = view.getUint8(0)
	switch (mode) {
		case 0:
			return
		case 2:
			console.log("Operating in mode 0 (Scoreboard enabled)")
			write_scoreboard(view)
			break
	}

	console.log("done")
}

socket.onerror = (error: Event) => {
	console.error("WebSocket Error: ", error)
}

socket.onclose = () => {
	console.log("WebSocket connection closed!")
}

console.log("TODO: hi from scoreboard.js (this always runs)")
