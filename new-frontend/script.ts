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

enum CardType { Yellow, Red }
// enum PlayerRole { Keeper, Field} TODO String?

interface Score { t1: number, t2: number }
interface Card {
	player_index: number,
	card_type: CardType
}
interface Player {
	name: string,
	team_index: number,
	role: string
}
interface Team {
	players_indices: number[],
	name: string,
	logo_filename: string, // logo als Bild direkt?
	color_left: number //Dark
	color_right: number, //Light
}
interface Game {
	t1_index: number,
	t2_index: number,
	halftimescore: Score,
	score: Score,
	cards: Card[]
}
interface Matchday {
	cur: {
		gameindex: number,
		halftime: boolean,
		pause: boolean,
		time: number,
		timestart: number // time_t
	},
	deftime: number,
	games: Game[],
	teams: Team[],
	players: Player[]
}

let md: Matchday

function parse_json(json: string): Matchday {
	const p = JSON.parse(json);
	const m: Partial<Matchday> = {};

	m.deftime = p.time;
	m.games = [];
	m.teams = [];
	m.players = [];
	for (let i = 0; i < p.teams.length; i++) {
		m.players[i*2] = {
			name: p.teams[i].players[0].name,
			role: p.teams[i].players[0].position,
			team_index: i
		};
		m.players[i*2 + 1] = {
				name: p.teams[i].players[1].name,
				role: p.teams[i].players[1].position,
				team_index: i
		};
		m.teams[i] = {
			players_indices: [i*2, i*2 + 1],
			name: p.teams[i].name,
			logo_filename: p.teams[i].logo,
			color_right: p.teams[i].color_light,
			color_left: p.teams[i].color_dark
		};
	}
	for (let i = 0; i < p.games.length; i++) {
		m.games[i] = {
			t1_index: m.teams.findIndex(temp => temp.name === p.games[i].team1),
			t2_index: m.teams.findIndex(temp => temp.name === p.games[i].team2),
			halftimescore: {t1: 0, t2: 0},
			score: {t1: 0, t2: 0},
			cards: []
		};
		if(m.games[i].t1_index === -1) console.log(`JSON Misformated: Game ${i} Team 1 not found: ${p.games[i].team1}`);
		if(m.games[i].t2_index === -1) console.log(`JSON Misformated: Game ${i} Team 2 not found: ${p.games[i].team2}`);
		if (p.games[i].score !== undefined) {
			m.games[i].score.t1 = p.games[i].score.team1;
			m.games[i].score.t2 = p.games[i].score.team2;
		}
		if (p.games[i].halftimescore !== undefined) {
			m.games[i].halftimescore.t1 = p.games[i].halftimescore.team1;
			m.games[i].halftimescore.t2 = p.games[i].halftimescore.team2;
		}
		if (p.games[i].cards !== undefined) {
			for(let j=0; j < p.games[j].cards.length; j++){
				m.games[i].cards[j] = {
					card_type: (p.games[i].cards[j].type === "Y") ? CardType.Yellow : CardType.Red,
					player_index: m.players.indexOf(p.games[i].cards[j].player)
				};
				if(m.games[i].cards[j].player_index === -1)
					console.log(`JSON Misformated: Game ${i} Card ${j} Player not found: ${p.games[i].cards[i].player}`);
			}
		}
	}

	return m as Matchday;
}

interface Color { r: number, g: number, b: number }

function Color_to_string(input: Color): string {
	return `rgb(${input.r}, ${input.g}, ${input.b})`
}

function Color_gradient_to_string(l: number, r: number): string {
	const lr = (l >> 16) & 0xFF;
	const lg = (l >> 8) & 0xFF;
	const lb = l & 0xFF;
	const rr = (r >> 16) & 0xFF;
	const rg = (r >> 8) & 0xFF;
	const rb = r & 0xFF;
	return `linear-gradient(90deg, rgb(${lr}, ${lg}, ${lb}) 0%,` +
		`rgb(${rr}, ${rg}, ${rb}) 50%)`
}

function Color_font_contrast(i: number): string {
	const r = (i >> 16) & 0xFF;
	const g = (i >> 8) & 0xFF;
	const b = i & 0xFF;
	return (Math.max(r, g, b) > 191) ? "black" : "white"
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

function write_scoreboard(m: Matchday) {
	console.log("Writing data to scoreboard:\n", m)

	const gamei = m.cur.gameindex
	const team1 = m.teams[m.games[gamei].t1_index]
	const team2 = m.teams[m.games[gamei].t2_index]
	scoreboard_t1.innerHTML = team1.name
	scoreboard_t2.innerHTML = team2.name

	scoreboard_score_1.innerHTML = m.games[gamei].score.t1.toString()
	scoreboard_score_2.innerHTML = m.games[gamei].score.t2.toString()

	const t1_col_right = team1.color_right
	const t1_col_left = team1.color_left
	const t2_col_right = team2.color_right
	const t2_col_left = team2.color_left

	//TODO colors
	scoreboard_t1.style.background = Color_gradient_to_string(t1_col_right, t1_col_left)
	scoreboard_t1.style.color = Color_font_contrast(t1_col_left)
	scoreboard_t2.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
	scoreboard_t2.style.color = Color_font_contrast(t2_col_left)
}

function write_gameplan(m: Matchday) {
	while (gameplan.children.length > 1)
		gameplan.removeChild(gameplan.lastChild!)

	const game_n = m.games.length
	const cur = m.cur.gameindex //TODO Index ab 0 so richtig?

	for (let game_i = 0; game_i < game_n; ++game_i) {
		const teams_1 = m.teams[m.games[game_i].t1_index].name
		const teams_2 = m.teams[m.games[game_i].t1_index].name
		const goals_1 = m.games[game_i].score.t1
		const goals_2 = m.games[game_i].score.t2
		const col_1_right = m.teams[m.games[game_i].t1_index].color_right
		const col_1_left = m.teams[m.games[game_i].t1_index].color_left
		const col_2_right = m.teams[m.games[game_i].t2_index].color_right
		const col_2_left = m.teams[m.games[game_i].t2_index].color_left

		let line = document.createElement("div")
		line.classList.add("line")

		let t1 = document.createElement("div")
		t1.classList.add("bordered", "t1")
		t1.innerHTML = teams_1[game_i].toString()
		t1.style.background = Color_gradient_to_string(col_1_right, col_1_left)
		t1.style.color = Color_font_contrast(col_1_right)
		line.appendChild(t1)

		let s1 = document.createElement("div")
		s1.classList.add("bordered", "s1")
		s1.innerHTML = goals_1.toString()
		line.appendChild(s1)

		let s2 = document.createElement("div")
		s2.classList.add("bordered", "s2")
		s2.innerHTML = goals_2.toString()
		line.appendChild(s2)

		let t2 = document.createElement("div")
		t2.classList.add("bordered", "t2")
		t2.innerHTML = teams_2.toString()
		t2.style.background = Color_gradient_to_string(col_2_right, col_2_left)
		t1.style.color = Color_font_contrast(col_2_right)
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

function write_gamestart(m: Matchday) {
	gamestart_t1.innerHTML = ""
	gamestart_t2.innerHTML = ""

	const gamei = m.cur.gameindex

	const t1_name = m.teams[m.games[gamei].t1_index].name
	const t2_name = m.teams[m.games[gamei].t2_index].name

	// TODO WIP
	const t1_keeper = m.players[m.teams[m.games[gamei].t1_index].players_indices[0]].name
	const t1_field = m.players[m.teams[m.games[gamei].t1_index].players_indices[1]].name
	const t2_keeper = m.players[m.teams[m.games[gamei].t2_index].players_indices[0]].name
	const t2_field = m.players[m.teams[m.games[gamei].t2_index].players_indices[1]].name

	const t1_col_left = m.teams[m.games[gamei].t1_index].color_left
	const t1_col_right = m.teams[m.games[gamei].t1_index].color_right
	const t2_col_left = m.teams[m.games[gamei].t2_index].color_left
	const t2_col_right = m.teams[m.games[gamei].t2_index].color_right

	const next_t1_name = m.teams[m.games[gamei+1].t1_index].name
	const next_t2_name = m.teams[m.games[gamei+1].t2_index].name
	const next_t1_color_left = m.teams[m.games[gamei+1].t1_index].color_left
	const next_t1_color_right = m.teams[m.games[gamei+1].t1_index].color_right
	const next_t2_color_left = m.teams[m.games[gamei+1].t2_index].color_left
	const next_t2_color_right = m.teams[m.games[gamei+1].t2_index].color_right

	const t1_el = document.createElement("div")
	t1_el.classList.add("team")

	const t1_name_el = document.createElement("div")
	t1_name_el.classList.add("bordered")
	t1_name_el.style.fontSize = "60px";
	t1_name_el.style.background = Color_gradient_to_string(t1_col_left, t1_col_right)
	t1_name_el.style.color = Color_font_contrast(t1_col_right)
	t1_name_el.innerHTML = t1_name.toString()

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
	t2_name_el.innerHTML = t2_name.toString()

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

	if (next_t1_name === "") gamestart_next.style.display = "none"
	else {
		gamestart_next.style.display = "block"
		gamestart_next_t1.innerHTML = next_t1_name
		gamestart_next_t1.style.background =
			Color_gradient_to_string(next_t1_color_left, next_t1_color_right)
		gamestart_next_t2.innerHTML = next_t2_name
		gamestart_next_t2.style.background =
			Color_gradient_to_string(next_t2_color_left, next_t2_color_right)
	}
}

// TODO refactor as handler function for receiving a card, also adding it to Matchday m
function write_card(view: DataView) {
	let offset = 1
	const is_red = view.getUint8(offset)

	let name: String = ""

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
	color_right?: number,
	color_left?: number
}

// TODO FINAL OPTIMIZE
function write_livetable(m: Matchday) {
	while (livetable.children.length > 2)
		livetable.removeChild(livetable.lastChild!)

	const team_n = m.teams.length
	let teams: LivetableLine[] = []

	for (let i = 0; i < team_n; ++i) {
		teams[i].name = m.teams[i].name;
		teams[i].points = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) { // TODO Count the game right now?
				if (m.games[j].t1_index === i) {
					p += (m.games[j].score.t1 - m.games[j].score.t2 > 0) ? 3 : 0
					p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
				} else if (m.games[j].t2_index === i) {
					p += (m.games[j].score.t1 - m.games[j].score.t2 < 0) ? 3 : 0
					p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
				}
			}
			return p
		}) (i, m)
		teams[i].played = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++)
				if(m.games[j].t1_index === i || m.games[j].t2_index === i) p++
			return p
		}) (i, m)
		teams[i].won = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) {
				if (m.games[j].t1_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 > 0) ? 1 : 0
				else if (m.games[j].t2_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 < 0) ? 1 : 0
			}
			return p
		}) (i, m)
		teams[i].tied = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) {
				if (m.games[j].t1_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
				else if (m.games[j].t2_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
			}
			return p
		}) (i, m)
		teams[i].lost = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) {
				if (m.games[j].t1_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 > 0) ? 0 : 1
				else if (m.games[j].t2_index === i)
					p += (m.games[j].score.t1 - m.games[j].score.t2 < 0) ? 0 : 1
			}
			return p
		}) (i, m)
		teams[i].goals = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) {
				if (m.games[j].t1_index === i) p += m.games[j].score.t1
				else if (m.games[j].t2_index === i) p += m.games[j].score.t2
			}
			return p
		}) (i, m)
		teams[i].goals_taken = ((i, m) => {
			let p: number = 0
			for (let j=0; j < m.cur.gameindex; j++) {
				if (m.games[j].t1_index === i) p += m.games[j].score.t2
				else if (m.games[j].t2_index === i) p += m.games[j].score.t1
			}
			return p
		}) (i, m)
		teams[i].color_right = m.teams[i].color_right
		teams[i].color_left = m.teams[i].color_left
	}

	for (let team_i = 0; team_i < team_n; ++team_i) {
		const line = document.createElement("div")
		line.classList.add("line")

		const name = document.createElement("div")
		name.innerHTML = teams[team_i].name!.toString()
		name.classList.add("bordered", "name")
		name.style.background = Color_gradient_to_string(teams[team_i].color_right!, teams[team_i].color_left!)
		name.style.color = Color_font_contrast(teams[team_i].color_right!)
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

//TODO transform this too
let DEFTIME = 420
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
	JSON = 123, // ASCII of: {
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
	if (typeof event.data !== "string") {
		console.error("Grrrrr, backend didnt sent a fucking string. Fuck off")
		return;
	}

	let buffer: string = event.data

	console.log("Received message: " + buffer)

	const mode: number = buffer.charCodeAt(0)
	console.log("mode: " + mode)
	switch (mode) {
		case WidgetMessage.JSON:
			console.log("Parsing JSON now");
			md = parse_json(buffer) //TODO Does this work?
			console.log("JSON parsed. Here it is:", md);
			break
		case WidgetMessage.WIDGET_SCOREBOARD:
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_SCOREBOARD + 1:
			scoreboard.style.display = "inline-flex"
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.opacity = "1", 10)
			write_scoreboard(md)
			break
		case WidgetMessage.WIDGET_LIVETABLE:
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_LIVETABLE + 1:
			livetable.style.display = "inline-flex"
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.opacity = "1", 10)
			write_livetable(md)
			break
		case WidgetMessage.WIDGET_GAMEPLAN:
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_GAMEPLAN + 1:
			gameplan.style.display = "inline-flex"
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.opacity = "1", 10)
			write_gameplan(md)
			break
		case WidgetMessage.WIDGET_GAMESTART:
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.display = "none", 500)
			break
		case WidgetMessage.WIDGET_GAMESTART + 1:
			gamestart.style.display = "flex"
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.opacity = "1", 10)
			write_gamestart(md)
			break
		case WidgetMessage.WIDGET_CARD_SHOW:
			card.style.display = "flex"
			card.style.opacity = "0"
			setTimeout(() => card.style.opacity = "1", 10)
			//write_card(view)
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
			//scoreboard_set_timer(view)
			break
		case WidgetMessage.SCOREBOARD_PAUSE_TIMER:
			//timer_is_paused = (view.getUint8(1) === 1)
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
