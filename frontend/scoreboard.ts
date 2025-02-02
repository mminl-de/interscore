let socket = new WebSocket("ws://localhost:8080", "interscore")
socket.binaryType = "arraybuffer"

let scoreboard = document.querySelector(".scoreboard")! as HTMLElement
let scoreboard_t1 = scoreboard.querySelector(".t1")!
let scoreboard_t2 = scoreboard.querySelector(".t2")!
let scoreboard_score_1 = scoreboard.querySelector(".score-1")!
let scoreboard_score_2 = scoreboard.querySelector(".score-2")!
let scoreboard_time_minutes = scoreboard.querySelector(".time .minutes")!
let scoreboard_time_seconds = scoreboard.querySelector(".time .seconds")!

let gameplan = document.querySelector(".gameplan")! as HTMLElement
let gameplan_t1 = document.querySelector(".gameplan .t1")!
let gameplan_t2 = document.querySelector(".gameplan .t2")!
let gameplan_score_1 = document.querySelector(".gameplan .score-1")!
let gameplan_score_2 = document.querySelector(".gameplan .score-2")!

let card_graphic = document.querySelector(".card-graphic")! as HTMLElement
let card_receiver = document.querySelector(".card-receiver")!
let card_message = document.querySelector(".card-message")!

const BUFFER_LEN = 100

function write_scoreboard(view: DataView) {
	console.log("Writing data to scoreboard:\n", view)

	let offset = 1
	let t1: String = ""
	let t2: String = ""
	for (let i = 0; i < BUFFER_LEN && !(view.getUint8(offset) == 0); ++i) {
		t1 += String.fromCharCode(view.getUint8(offset))
		++offset
	}
	offset = 1
	for (let i = 0; i < BUFFER_LEN && !(view.getUint8(offset) == 0); ++i) {
		t2 += String.fromCharCode(view.getUint8(BUFFER_LEN + offset))
		++offset
	}
	scoreboard_t1.innerHTML = t1.toString()
	scoreboard_t2.innerHTML = t2.toString()

	scoreboard_score_1.innerHTML = view.getUint8(offset).toString()
	++offset
	scoreboard_score_2.innerHTML = view.getUint8(offset).toString()
	++offset

	// TODO
	//const is_halftime = view.getUint8(offset)
	//++offset
}

function write_gameplan(view: DataView) {
	let offset = 1
	const games_n = view.getUint8(offset)
	++offset

	for (let game = 0; game < games_n; ++game) {
		let t1: String = ""
		let t2: String = ""
		for (let name_char = 0; name_char < BUFFER_LEN; ++name_char) {
			t1 += String.fromCharCode(view.getUint8(offset))
			t2 += String.fromCharCode(view.getUint8(offset + games_n * BUFFER_LEN))
			++offset
		}
		gameplan_t1.innerHTML = t1.toString()
		gameplan_t2.innerHTML = t2.toString()
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

function scoreboard_set_timer(view: DataView) {
	let offset = 1
	const time_in_s = view.getUint16(offset)
	scoreboard_time_minutes.innerHTML = Math.floor(time_in_s / 60).toString().padStart(2, "0")
	scoreboard_time_seconds.innerHTML = (time_in_s % 60).toString().padStart(2, "0")
	start_timer(time_in_s)
}

// TODO FINAL MOVE TOP
let countdown: number
let remaining_time = 0
function start_timer(time_in_s: number) {
	clearInterval(countdown)
	remaining_time = time_in_s
	update_display()

	countdown = setInterval(() => {
		if (remaining_time > 0)  {
			--remaining_time
			update_display()
		} else clearInterval(countdown)
	}, 1000)
}

let timer_is_paused = false
function scoreboard_pause_timer() {
	clearInterval(countdown)
	timer_is_paused = true
}

function update_display() {
	const minutes = Math.floor(remaining_time / 60).toString().padStart(2, "0")
	const seconds = (remaining_time % 60).toString().padStart(2, "0")
	scoreboard_time_minutes.innerHTML = minutes
	scoreboard_time_seconds.innerHTML = seconds
}

socket.onopen = () => {
	console.log("Connected to WebSocket server!")
}

socket.onmessage = (event: MessageEvent) => {
	// TODO
	if (!(event.data instanceof ArrayBuffer))
		console.error("Sent data is not in proper binary format!")

	let buffer = event.data
	let view = new DataView(buffer)

	const mode = view.getUint8(0)
	switch (mode) {
		case 0:
			return
		case 1:
			scoreboard.style.display = "none"
			break
		case 2:
			scoreboard.style.display = "inline-flex"
			write_scoreboard(view)
			break
		//case 3:
		//	// TODO WIP
		//	livetable.style.display = "none"
		//	break
		//case 4:
		//	// TODO WIP
		//	livetable.style.display = "inline-flex"
		//	break
		case 5:
			// TODO WIP
			gameplan.style.display = "none"
			break
		case 6:
			// TODO WIP
			gameplan.style.display = "inline-flex"
			break
		case 9:
			console.log("Updating timer")
			scoreboard_set_timer(view)
			break
		case 10:
			if (timer_is_paused) {
				console.log("Resuming timer")
				start_timer(remaining_time)
			} else {
				console.log("Pausing timer")
				scoreboard_pause_timer()
			}
			break
		// TODO
		default:
			console.log("TODO not a classical mode, anyways, here's the data: ", view)
			break
	}
}

socket.onerror = (error: Event) => {
	console.error("WebSocket Error: ", error)
}

socket.onclose = () => {
	console.log("WebSocket connection closed!")
}

console.log("Client loaded!")
