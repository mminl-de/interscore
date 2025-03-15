// TODO FINAL OPTIMIZE our shame
// TODO FINAL check if each handle is used
let socket = new WebSocket("ws://localhost:8081?client=frontend", "interscore")
socket.binaryType = "arraybuffer"

const scoreboard = document.querySelector(".scoreboard")! as HTMLElement
let scoreboard_t1 = scoreboard.querySelector(".t1")! as HTMLElement
let scoreboard_t2 = scoreboard.querySelector(".t2")! as HTMLElement
let scoreboard_score_1 = scoreboard.querySelector(".s1")!
let scoreboard_score_2 = scoreboard.querySelector(".s2")!
let scoreboard_time_bar = scoreboard.querySelector(".time-container .bar")! as HTMLElement
let scoreboard_time_minutes = scoreboard.querySelector(".time .minutes")!
let scoreboard_time_seconds = scoreboard.querySelector(".time .seconds")!

const gameplan = document.querySelector(".gameplan")! as HTMLElement

const gamestart = document.querySelector(".gamestart")! as HTMLElement
let gamestart_container = document.querySelector(".gamestart .container")! as HTMLElement

const card = document.querySelector(".card")! as HTMLElement
let card_graphic = card.querySelector(".card-graphic")! as HTMLElement
let card_receiver = card.querySelector(".card-receiver")!
let card_message = card.querySelector(".card-message")!

const livetable = document.querySelector(".livetable")! as HTMLElement

const decoder = new TextDecoder("utf-8")
let str_len: number // temporary variable for counting string lengths
let u8_array: Uint8Array

const BUFFER_LEN = 100
const GAMES_COUNT_MAX = 64
const TEAMS_COUNT_MAX = 32
const TEAM_NAME_MAX_LEN = 100
const PLAYER_NAME_MAX_LEN = 100

interface Color { r: number, g: number, b: number }

function Color_to_string(input: Color): string {
	return `rgb(${input.r}, ${input.g}, ${input.b})`
}

function Color_gradient_to_string(left: Color, right: Color): string {
	return `linear-gradient(90deg, rgb(${left.r}, ${left.g}, ${left.b}) 0%,` +
		`rgb(${right.r}, ${right.g}, ${right.b}) 50%)`
}

function read_string(view: DataView, offset: number): string {
	str_len = 0
	while (view.getUint8(offset + str_len) !== 0) ++str_len
	u8_array = new Uint8Array(view.buffer, view.byteOffset + offset, str_len)
	return decoder.decode(u8_array)
}

function read_color(view: DataView, offset: number): Color {
	return {
		r: view.getUint8(offset),
		g: view.getUint8(offset + 1),
		b: view.getUint8(offset + 2),
	}
}

function write_scoreboard(view: DataView) {
	console.log("Writing data to scoreboard:\n", view)

	let offset = 1
	let t1: String = ""
	let t2: String = ""
	for (let i = 0; i < BUFFER_LEN && view.getUint8(offset) != 0; ++i) {
		t1 += String.fromCharCode(view.getUint8(offset))
		++offset
	}
	offset = 1
	for (let i = 0; i < BUFFER_LEN && view.getUint8(offset) != 0; ++i) {
		t2 += String.fromCharCode(view.getUint8(BUFFER_LEN + offset))
		++offset
	}
	scoreboard_t1.innerHTML = t1.toString()
	scoreboard_t2.innerHTML = t2.toString()

	offset = 1 + BUFFER_LEN * 2
	scoreboard_score_1.innerHTML = view.getUint8(offset).toString()
	++offset
	scoreboard_score_2.innerHTML = view.getUint8(offset).toString()
	++offset

	++offset // ignoring is_halftime TODO

	const t1_col_left: Color = {
		r: view.getUint8(offset),
		g: view.getUint8(offset + 1),
		b: view.getUint8(offset + 2)
	}
	offset += 3

	const t1_col_right: Color = {
		r: view.getUint8(offset),
		g: view.getUint8(offset + 1),
		b: view.getUint8(offset + 2)
	}
	offset += 3

	const t2_col_left: Color = {
		r: view.getUint8(offset),
		g: view.getUint8(offset + 1),
		b: view.getUint8(offset + 2)
	}
	offset += 3

	const t2_col_right: Color = {
		r: view.getUint8(offset),
		g: view.getUint8(offset + 1),
		b: view.getUint8(offset + 2)
	}
	offset += 3

	//scoreboard_t1.style.backgroundColor = Color_to_string(t1_col_left)
	scoreboard_t1.style.background = Color_gradient_to_string(t1_col_right, t1_col_left)
	scoreboard_t2.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
}

function write_gameplan(view: DataView) {
	while (gameplan.children.length > 1)
		gameplan.removeChild(gameplan.lastChild!)

	let offset = 1
	const game_n = view.getUint8(offset)
	++offset

	const cur = view.getUint8(offset)
	console.log("cur is ", cur)
	++offset

	let teams_1: String[] = []
	let teams_2: String[] = []
	for (let game_i = 0; game_i < game_n; ++game_i) {
		let t1: String = ""
		for (let name_ch = 0; name_ch < BUFFER_LEN; ++name_ch) {
			const c = view.getUint8(offset)
			t1 += String.fromCharCode(c)
			++offset
			if (c === 0) {
				offset += BUFFER_LEN - name_ch - 1
				break
			}
		}
		teams_1.push(t1)
	}
	offset += (GAMES_COUNT_MAX - game_n) * BUFFER_LEN

	for (let game_i = 0; game_i < game_n; ++game_i) {
		let t2: String = ""
		for (let name_ch = 0; name_ch < BUFFER_LEN; ++name_ch) {
			const c = view.getUint8(offset)
			t2 += String.fromCharCode(c)
			++offset
			if (c === 0) {
				offset += BUFFER_LEN - name_ch - 1
				break
			}
		}
		teams_2.push(t2)
	}
	offset += (GAMES_COUNT_MAX - game_n) * BUFFER_LEN

	let goals_1: number[] = []
	for (let goal_i = 0; goal_i < game_n; ++goal_i) {
		goals_1.push(view.getUint8(offset))
		++offset
	}
	offset += GAMES_COUNT_MAX - game_n

	let goals_2: number[] = []
	for (let goal_i = 0; goal_i < game_n; ++goal_i) {
		goals_2.push(view.getUint8(offset))
		++offset
	}
	offset += GAMES_COUNT_MAX - game_n

	let col_1_light: Color[] = []
	let col_2_light: Color[] = []
	for (let game_i = 0; game_i < game_n; ++game_i) {
		// TODO OPTIMIZE
		let c1: Color = { r: 0, g: 0, b: 0 }
		let c2: Color = { r: 0, g: 0, b: 0 }
		c1.r = view.getUint8(offset)
		c2.r = view.getUint8(offset + 2 * GAMES_COUNT_MAX * 3)

		c1.g = view.getUint8(offset + 1)
		c2.g = view.getUint8(offset + 1 + 2 * GAMES_COUNT_MAX * 3)

		c1.b = view.getUint8(offset + 2)
		c2.b = view.getUint8(offset + 2 + 2 * GAMES_COUNT_MAX * 3)

		offset += 3

		col_1_light.push(c1)
		col_2_light.push(c2)
	}
	offset += (GAMES_COUNT_MAX - game_n) * 3

	let col_1_dark: Color[] = []
	let col_2_dark: Color[] = []
	for (let game_i = 0; game_i < game_n; ++game_i) {
		let c1: Color = { r: 0, g: 0, b: 0 }
		let c2: Color = { r: 0, g: 0, b: 0 }
		c1.r = view.getUint8(offset)
		c2.r = view.getUint8(offset + 2 * GAMES_COUNT_MAX * 3)

		c1.g = view.getUint8(offset + 1)
		c2.g = view.getUint8(offset + 1 + 2 * GAMES_COUNT_MAX * 3)

		c1.b = view.getUint8(offset + 2)
		c2.b = view.getUint8(offset + 2 + 2 * GAMES_COUNT_MAX * 3)

		offset += 3

		col_1_dark.push(c1)
		col_2_dark.push(c2)
	}
	offset += (GAMES_COUNT_MAX - game_n) * 3

	for (let game_i = 0; game_i < game_n; ++game_i) {
		let line = document.createElement("div")
		line.classList.add("line")

		let t1 = document.createElement("div")
		t1.classList.add("bordered", "t1")
		t1.innerHTML = teams_1[game_i].toString()
		t1.style.background = Color_gradient_to_string(col_1_light[game_i], col_1_dark[game_i])
		line.appendChild(t1)

		let s1 = document.createElement("div")
		s1.classList.add("bordered", "s1")
		s1.innerHTML = goals_1[game_i].toString()
		line.appendChild(s1)

		let s2 = document.createElement("div")
		s2.classList.add("bordered", "s2")
		s2.innerHTML = goals_2[game_i].toString()
		line.appendChild(s2)

		let t2 = document.createElement("div")
		t2.classList.add("bordered", "t2")
		t2.style.background = Color_gradient_to_string(col_2_light[game_i], col_2_dark[game_i])
		t2.innerHTML = teams_2[game_i].toString()
		line.appendChild(t2)

		if (cur < game_i) {
			line.style.opacity = "0.9"
			s1.innerHTML = "?"
			s2.innerHTML = "?"
		}

		gameplan.appendChild(line)
	}
}

function write_gamestart(view: DataView) {
	while (gamestart_container.children.length > 0)
		gamestart_container.removeChild(gamestart_container.lastChild!)

	let offset = 1

	// TODO REMOVE
	let t1: string = ""
	let t2: string = ""

	for (let t1_ch = 0; t1_ch < TEAM_NAME_MAX_LEN; ++t1_ch) {
		const c = view.getUint8(offset)
		t1 += String.fromCharCode(c)
		++offset
		if (c === 0) {
			offset += TEAM_NAME_MAX_LEN - t1_ch - 1
			break
		}
	}
	console.log("TODO tactical t1 print: ", t1)

	for (let t2_ch = 0; t2_ch < TEAM_NAME_MAX_LEN; ++t2_ch) {
		const c = view.getUint8(offset)
		t2 += String.fromCharCode(c)
		++offset
		if (c === 0) {
			offset += TEAM_NAME_MAX_LEN - t2_ch - 1
			break
		}
	}
	console.log("TODO tactical t2 print: ", t2)

	// TODO WIP
	const t1_keeper = read_string(view, offset)
	offset += PLAYER_NAME_MAX_LEN
	console.log("TODO 1 keeper: ", t1_keeper)

	// TODO WIP
	const t1_field = read_string(view, offset)
	offset += PLAYER_NAME_MAX_LEN
	console.log("TODO 1 keeper: ", t1_field)

	// TODO WIP
	const t2_keeper = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN
	console.log("TODO 2 keeper: ", t2_keeper)

	// TODO WIP
	const t2_field = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN
	console.log("TODO 2 field: ", t2_field)

	let t1_col_left = read_color(view, offset)
	offset += 3
	console.log(Color_to_string(t1_col_left))

	let t1_col_right = read_color(view, offset)
	offset += 3
	console.log(Color_to_string(t1_col_right))

	let t2_col_left = read_color(view, offset)
	offset += 3

	let t2_col_right = read_color(view, offset)
	offset += 3

	const t1_el = document.createElement("div")
	t1_el.classList.add("team")

	const t1_name_el = document.createElement("div")
	t1_name_el.classList.add("bordered")
	t1_name_el.style.fontSize = "60px";
	t1_name_el.style.background = Color_gradient_to_string(t1_col_left, t1_col_right)
	t1_name_el.innerHTML = t1.toString()

	const t1_keeper_el = document.createElement("div")
	t1_keeper_el.classList.add("bordered", "player")
	t1_keeper_el.style.backgroundColor = "#bebebe"
	t1_keeper_el.innerHTML = t1_keeper

	const t1_field_el = document.createElement("div")
	t1_field_el.classList.add("bordered", "player")
	t1_field_el.style.backgroundColor = "#bebebe"
	t1_field_el.innerHTML = t1_field

	t1_el.appendChild(t1_name_el)
	t1_el.appendChild(t1_keeper_el)
	t1_el.appendChild(t1_field_el)

	gamestart_container.appendChild(t1_el)

	const t2_el = document.createElement("div")
	t2_el.classList.add("team")

	const t2_name_el = document.createElement("div")
	t2_name_el.classList.add("bordered")
	t2_name_el.style.fontSize = "60px";
	t2_name_el.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
	t2_name_el.innerHTML = t2.toString()

	const t2_keeper_el = document.createElement("div")
	t2_keeper_el.classList.add("bordered", "player")
	t2_keeper_el.style.backgroundColor = "#bebebe"
	t2_keeper_el.innerHTML = t2_keeper

	const t2_field_el = document.createElement("div")
	t2_field_el.classList.add("bordered", "player")
	t2_field_el.style.backgroundColor = "#bebebe"
	t2_field_el.innerHTML = t2_field

	t2_el.appendChild(t2_name_el)
	t2_el.appendChild(t2_keeper_el)
	t2_el.appendChild(t2_field_el)

	gamestart_container.appendChild(t2_el)
}

function write_card(view: DataView) {
	let offset = 1

	const is_red = view.getUint8(offset)
	++offset

	let name: String = ""
	for (let name_ch = 0; name_ch < PLAYER_NAME_MAX_LEN; ++name_ch) {
		const c = view.getUint8(offset)
		name += String.fromCharCode(c)
		++offset
		if (c === 0) {
			offset += PLAYER_NAME_MAX_LEN - name_ch - 1
			break
		}
	}

	card_receiver.innerHTML = name.toString()
	if (is_red === 1) {
		card_graphic.style.backgroundColor = "#ff0000"
		card_message.innerHTML = "bekommt eine rote Karte"
	} else {
		card_graphic.style.backgroundColor = "#ffff00"
		card_message.innerHTML = "bekommt eine gelbe Karte"
	}

	setTimeout(() => {
		card.style.opacity = "0"
		setTimeout(() => card.style.display = "none", 500)
	}, 7_000)
}

interface LivetableLine {
	name?: string,
	points?: number,
	played?: number,
	won?: number,
	tied?: number,
	lost?: number,
	goals?: number,
	goals_taken?: number,
	color_light?: Color,
	color_dark?: Color
}

// TODO FINAL OPTIMIZE
function write_livetable(view: DataView) {
	while (livetable.children.length > 2)
		livetable.removeChild(livetable.lastChild!)

	let offset = 1

	const team_n = view.getUint8(offset)
	++offset

	let teams: LivetableLine[] = []

	for (let i = 0; i < team_n; ++i) {
		teams[i] = { name: "" }
		for (let ch_i = 0; ch_i < BUFFER_LEN; ++ch_i) {
			const c = view.getUint8(offset)
			teams[i].name += String.fromCharCode(c)
			++offset
			if (c === 0) {
				offset += BUFFER_LEN - ch_i - 1
				break
			}
		}
	}
	offset += (TEAMS_COUNT_MAX - team_n) * TEAM_NAME_MAX_LEN

	for (let i = 0; i < team_n; ++i) {
		teams[i].points = view.getUint8(offset)
		++offset
	}
	offset += TEAMS_COUNT_MAX - team_n

	for (let i = 0; i < team_n; ++i) {
		teams[i].played = view.getUint8(offset)
		++offset
	}
	offset += TEAMS_COUNT_MAX - team_n

	for (let i = 0; i < team_n; ++i) {
		teams[i].won = view.getUint8(offset)
		++offset
	}
	offset += TEAMS_COUNT_MAX - team_n

	for (let i = 0; i < team_n; ++i) {
		teams[i].tied = view.getUint8(offset)
		++offset
	}
	offset += TEAMS_COUNT_MAX - team_n

	for (let i = 0; i < team_n; ++i) {
		teams[i].lost = view.getUint8(offset)
		++offset
	}
	offset += TEAMS_COUNT_MAX - team_n

	for (let i = 0; i < team_n; ++i) {
		teams[i].goals = view.getUint16(offset, true)
		if (view.getUint16(offset) === 6) console.log("amogus")
		offset += 2
	}
	offset += (TEAMS_COUNT_MAX - team_n) * 2

	for (let i = 0; i < team_n; ++i) {
		teams[i].goals_taken = view.getUint16(offset, true)
		offset += 2
	}
	offset += (TEAMS_COUNT_MAX - team_n) * 2

	for (let i = 0; i < team_n; ++i) {
		teams[i].color_light = {
			r: view.getUint8(offset),
			g: view.getUint8(offset + 1),
			b: view.getUint8(offset + 2)
		}
		teams[i].color_dark = {
			r: view.getUint8(offset + TEAMS_COUNT_MAX * 3),
			g: view.getUint8(offset + TEAMS_COUNT_MAX * 3 + 1),
			b: view.getUint8(offset + TEAMS_COUNT_MAX * 3 + 2)
		}
		offset += 3
	}

	for (let team_i = 0; team_i < team_n; ++team_i) {
		const line = document.createElement("div")
		line.classList.add("line")

		const name = document.createElement("div")
		name.innerHTML = teams[team_i].name!.toString()
		name.classList.add("bordered", "name")
		name.style.background = Color_gradient_to_string(teams[team_i].color_light!, teams[team_i].color_dark!)
		name.style.color = "#bebebe"
		line.appendChild(name)

		const points = document.createElement("div")
		points.innerHTML = teams[team_i].points!.toString()
		points.classList.add("bordered")
		line.appendChild(points)

		const played = document.createElement("div")
		played.innerHTML = teams[team_i].played!.toString()
		played.classList.add("bordered")
		line.appendChild(played)

		const won = document.createElement("div")
		won.innerHTML = teams[team_i].won!.toString()
		won.classList.add("bordered")
		line.appendChild(won)

		const tied = document.createElement("div")
		tied.innerHTML = teams[team_i].tied!.toString()
		tied.classList.add("bordered")
		line.appendChild(tied)

		const lost = document.createElement("div")
		lost.innerHTML = teams[team_i].lost!.toString()
		lost.classList.add("bordered")
		line.appendChild(lost)

		const goals = document.createElement("div")
		goals.innerHTML = `${teams[team_i].goals!.toString()}:${teams[team_i].goals_taken!.toString()}`
		goals.classList.add("bordered")
		line.appendChild(goals)

		const diff = document.createElement("div")
		diff.innerHTML = (teams[team_i].goals! - teams[team_i].goals_taken!).toString()
		diff.classList.add("bordered")
		line.appendChild(diff)

		livetable.appendChild(line)
	}
}

let DEFTIME = 420 //TODO send this at the beginning from backend to frontend as its defined in input.json
let countdown = 0
//let duration = 0
let remaining_time = 0
let timer_is_paused = true

function scoreboard_set_timer(view: DataView) {
	clearInterval(countdown)

	let offset = 1
	const time_in_s = view.getUint16(offset)
	remaining_time = time_in_s
	//duration = time_in_s
	//scoreboard_time_bar.style.width = "100%"

	update_timer_html()
	countdown = setInterval(() => {
		if (timer_is_paused) return
		if (remaining_time <= 1) clearInterval(countdown)

		--remaining_time

		const bar_width = Math.min(Math.max(0, (remaining_time / DEFTIME) * 100), 100)
		scoreboard_time_bar.style.width = bar_width + "%"
		update_timer_html()
	}, 1000)
}

function update_timer_html() {
	const minutes = Math.floor(remaining_time / 60).toString().padStart(2, "0")
	const seconds = (remaining_time % 60).toString().padStart(2, "0")
	scoreboard_time_minutes.innerHTML = minutes
	scoreboard_time_seconds.innerHTML = seconds
}

socket.onopen = () => {
	console.log("Connected to WebSocket server!")
}

enum WidgetMessage {
	WIDGET_SCOREBOARD = 1,
	WIDGET_LIVETABLE = 3,
	WIDGET_GAMEPLAN = 5,
	WIDGET_GAMESTART = 7,
	WIDGET_CARD_SHOW = 9,
	SCOREBOARD_SET_TIMER = 10,
	SCOREBOARD_PAUSE_TIMER = 11
}

socket.onmessage = (event: MessageEvent) => {
	if (!(event.data instanceof ArrayBuffer))
		console.error("Sent data is not in proper binary format!")

	let buffer = event.data
	let view = new DataView(buffer)

	const mode = view.getUint8(0)
	switch (mode) {
		case 0:
			return
		case WidgetMessage.WIDGET_SCOREBOARD:
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_SCOREBOARD + 1:
			scoreboard.style.display = "inline-flex"
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.opacity = "1", 10)
			write_scoreboard(view)
			break
		case WidgetMessage.WIDGET_LIVETABLE:
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_LIVETABLE + 1:
			livetable.style.display = "inline-flex"
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.opacity = "1", 10)
			write_livetable(view)
			break
		case WidgetMessage.WIDGET_GAMEPLAN:
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_GAMEPLAN + 1:
			gameplan.style.display = "inline-flex"
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.opacity = "1", 10)
			write_gameplan(view)
			break
		case WidgetMessage.WIDGET_GAMESTART:
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_GAMESTART + 1:
			gamestart.style.display = "flex"
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.opacity = "1", 10)
			write_gamestart(view)
			break
		case WidgetMessage.WIDGET_CARD_SHOW:
			card.style.display = "flex"
			card.style.opacity = "0"
			setTimeout(() => card.style.opacity = "1", 10)
			write_card(view)
			break
		case WidgetMessage.SCOREBOARD_SET_TIMER:
			scoreboard_set_timer(view)
			break
		case WidgetMessage.SCOREBOARD_PAUSE_TIMER:
			timer_is_paused = (view.getUint8(1) === 1)
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

//function hotReloadCSS() {
//  document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
//    const newLink = document.createElement('link')
//    newLink.rel = 'stylesheet'
//    newLink.href = (link as HTMLLinkElement).href.split('?')[0] + '?' + new Date().getTime()
//    link.replaceWith(newLink)
//  })
//}
//
//setInterval(hotReloadCSS, 5000)
