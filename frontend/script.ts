// TODO NOTE dont ever hardcode styles :pray:
// TODO FINAL OPTIMIZE our shame
// TODO FINAL check if each handle is used
// TODO rewrite string reading
let socket = new WebSocket("ws://localhost:8081?client=frontend", "interscore")
socket.binaryType = "arraybuffer"

const scoreboard = document.querySelector(".scoreboard")! as HTMLElement
const scoreboard_t1 = scoreboard.querySelector(".t1")! as HTMLElement
const scoreboard_t2 = scoreboard.querySelector(".t2")! as HTMLElement
const scoreboard_score_1 = scoreboard.querySelector(".s1")!
const scoreboard_score_2 = scoreboard.querySelector(".s2")!
const scoreboard_time_bar = scoreboard.querySelector(".time-container .bar")! as HTMLElement
const scoreboard_time_minutes = scoreboard.querySelector(".time .minutes")!
const scoreboard_time_seconds = scoreboard.querySelector(".time .seconds")!

const gameplan = document.querySelector(".gameplan")! as HTMLElement
const scroller = document.querySelector(".gameplan-container .scroller")! as HTMLElement

// TODO CHECK if we still need this one
const gamestart = document.querySelector(".gamestart")! as HTMLElement
// TODO CHECK if we still need this one
const gamestart_container = document.querySelector(".gamestart .container")! as HTMLElement
const gamestart_t1 = gamestart.querySelector(".t1")! as HTMLElement
const gamestart_t2 = gamestart.querySelector(".t2")! as HTMLElement
const gamestart_next = gamestart.querySelector(".next")! as HTMLElement
const gamestart_next_t1 = gamestart_next.querySelector(".t1")! as HTMLElement
const gamestart_next_t2 = gamestart_next.querySelector(".t2")! as HTMLElement

const card = document.querySelector(".card")! as HTMLElement
const card_graphic = card.querySelector(".card-graphic")! as HTMLElement
const card_receiver = card.querySelector(".card-receiver")!
const card_message = card.querySelector(".card-message")!

const ad = document.querySelector(".ad")! as HTMLElement

const livetable = document.querySelector(".livetable")! as HTMLElement

const decoder = new TextDecoder("utf-8")
let str_len: number // temporary variable for counting string lengths
let u8_array: Uint8Array

const BUFFER_LEN = 100
const GAMES_COUNT_MAX = 64
const TEAMS_COUNT_MAX = 32
const TEAM_NAME_MAX_LEN = 100
const PLAYER_NAME_MAX_LEN = 100
const SCROLL_DURATION = 7_000

interface Color { r: number, g: number, b: number }

function Color_to_string(input: Color): string {
	return `rgb(${input.r}, ${input.g}, ${input.b})`
}

function Color_gradient_to_string(left: Color, right: Color): string {
	return `linear-gradient(90deg, rgb(${left.r}, ${left.g}, ${left.b}) 0%,` +
		`rgb(${right.r}, ${right.g}, ${right.b}) 50%)`
}

function Color_font_contrast(input: Color): string {
	return (Math.max(input.r, input.g, input.b) > 191) ? "black" : "white"
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
	for (let i = 0; i < BUFFER_LEN && view.getUint8(BUFFER_LEN + offset) != 0; ++i) {
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

	++offset // Ignore is_halftime TODO

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

	scoreboard_t1.style.background = Color_gradient_to_string(t1_col_right, t1_col_left)
	scoreboard_t1.style.color = Color_font_contrast(t1_col_left)
	scoreboard_t2.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
	scoreboard_t2.style.color = Color_font_contrast(t2_col_left)
}

function write_gameplan(view: DataView) {
	while (gameplan.children.length > 1)
		gameplan.removeChild(gameplan.lastChild!)

	let offset = 1
	const game_n = view.getUint8(offset)
	++offset

	const cur = view.getUint8(offset)
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
		t1.style.color = Color_font_contrast(col_1_light[game_i])
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
		t2.innerHTML = teams_2[game_i].toString()
		t2.style.background = Color_gradient_to_string(col_2_light[game_i], col_2_dark[game_i])
		t1.style.color = Color_font_contrast(col_2_light[game_i])
		line.appendChild(t2)

		if (cur < game_i) {
			line.style.opacity = "0.9"
			s1.innerHTML = "?"
			s2.innerHTML = "?"
			t1.style.color = "#bebebe"
			t2.style.color = "#bebebe"
			s1.style.color = "#bebebe"
			s2.style.color = "#bebebe"
			s1.style.backgroundColor = "black"
			s2.style.backgroundColor = "black"
		}

		gameplan.appendChild(line)
	}

	// TODO
	function smoothScrollTo(targetY, duration = 2_000) {
		const startY = scroller.scrollTop
		const deltaY = targetY - startY
		const startTime = performance.now()

		function step(currentTime) {
			const elapsed = currentTime - startTime
			const progress = Math.min(elapsed / duration, 1)
			const eased = progress < 0.5
				? 2 * progress * progress // easeIn
				: -1 + (4 - 2 * progress) * progress // easeOut

			scroller.scrollTop = startY + deltaY * eased

			if (progress < 1) {
				requestAnimationFrame(step)
			}
		}

		requestAnimationFrame(step)
	}

	if (game_n > 10) {
		gameplan.parentElement?.classList.add("masked")
		setTimeout(() => {
			smoothScrollTo(scroller.scrollHeight, SCROLL_DURATION)

			setTimeout(() => {
				smoothScrollTo(0, SCROLL_DURATION)
			}, SCROLL_DURATION + 2000) // duration + delay
		}, 2000)
	}
}

function write_gamestart(view: DataView) {
	gamestart_t1.innerHTML = ""
	gamestart_t2.innerHTML = ""

	let offset = 1

	const t1 = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	const t2 = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	// TODO WIP
	const t1_keeper = read_string(view, offset)
	offset += PLAYER_NAME_MAX_LEN

	// TODO WIP
	const t1_field = read_string(view, offset)
	offset += PLAYER_NAME_MAX_LEN

	// TODO WIP
	const t2_keeper = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	// TODO WIP
	const t2_field = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	const t1_col_left = read_color(view, offset)
	offset += 3

	const t1_col_right = read_color(view, offset)
	offset += 3

	const t2_col_left = read_color(view, offset)
	offset += 3

	const t2_col_right = read_color(view, offset)
	offset += 3

	// TODO WIP
	const next_t1 = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	const next_t2 = read_string(view, offset)
	offset += TEAM_NAME_MAX_LEN

	const next_t1_color_left = read_color(view, offset)
	offset += 3

	const next_t1_color_right = read_color(view, offset)
	offset += 3

	const next_t2_color_left = read_color(view, offset)
	offset += 3

	const next_t2_color_right = read_color(view, offset)
	offset += 3

	const t1_el = document.createElement("div")
	t1_el.classList.add("team")

	const t1_name_el = document.createElement("div")
	t1_name_el.classList.add("bordered")
	t1_name_el.style.fontSize = "60px";
	t1_name_el.style.background = Color_gradient_to_string(t1_col_left, t1_col_right)
	t1_name_el.style.color = Color_font_contrast(t1_col_right)
	t1_name_el.innerHTML = t1.toString()

	const t1_keeper_el = document.createElement("div")
	t1_keeper_el.classList.add("bordered", "player")
	t1_keeper_el.style.backgroundColor = "#bebebe"
	t1_keeper_el.innerHTML = t1_keeper

	const t1_field_el = document.createElement("div")
	t1_field_el.classList.add("bordered", "player")
	t1_field_el.style.backgroundColor = "#bebebe"
	t1_field_el.innerHTML = t1_field

	gamestart_t1.appendChild(t1_name_el)
	gamestart_t1.appendChild(t1_keeper_el)
	gamestart_t1.appendChild(t1_field_el)

	const t2_name_el = document.createElement("div")
	t2_name_el.classList.add("bordered")
	t2_name_el.style.fontSize = "60px";
	t2_name_el.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
	t2_name_el.style.color = Color_font_contrast(t2_col_left)
	t2_name_el.innerHTML = t2.toString()

	const t2_keeper_el = document.createElement("div")
	t2_keeper_el.classList.add("bordered", "player")
	t2_keeper_el.style.backgroundColor = "#bebebe"
	t2_keeper_el.innerHTML = t2_keeper

	const t2_field_el = document.createElement("div")
	t2_field_el.classList.add("bordered", "player")
	t2_field_el.style.backgroundColor = "#bebebe"
	t2_field_el.innerHTML = t2_field

	gamestart_t2.appendChild(t2_name_el)
	gamestart_t2.appendChild(t2_keeper_el)
	gamestart_t2.appendChild(t2_field_el)

	if (next_t1 === "") gamestart_next.style.display = "none"
	else {
		gamestart_next.style.display = "block"
		gamestart_next_t1.innerHTML = next_t1
		gamestart_next_t1.style.background =
			Color_gradient_to_string(next_t1_color_left, next_t1_color_right)
		gamestart_next_t2.innerHTML = next_t2
		gamestart_next_t2.style.background =
			Color_gradient_to_string(next_t2_color_left, next_t2_color_right)
	}
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
		name.style.color = Color_font_contrast(teams[team_i].color_light!)
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
let remaining_time = 0
let timer_is_paused = true

function scoreboard_set_timer(view: DataView) {
	clearInterval(countdown)

	let offset = 1
	const time_in_s = view.getUint16(offset)
	remaining_time = time_in_s

	update_timer_html()
	countdown = setInterval(() => {
		if (timer_is_paused) return
		if (remaining_time <= 1) clearInterval(countdown)

		--remaining_time

		const bar_width = Math.max(0, (remaining_time / DEFTIME) * 100)
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
	WIDGET_AD = 10,
	SCOREBOARD_SET_TIMER = 12,
	SCOREBOARD_PAUSE_TIMER = 13
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
		case WidgetMessage.WIDGET_AD:
			ad.style.opacity = "0"
			setTimeout(() => ad.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_AD + 1:
			ad.style.display = "block"
			ad.style.opacity = "0"
			setTimeout(() => ad.style.opacity = "1", 10)
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

// For debugging
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
