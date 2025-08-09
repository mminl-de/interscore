import { MessageType } from "../MessageType.js"
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// MessageType.ts contains only the enum MessageType and is exported, so backend
// and rentnerend can use it as well (through #define magic)


// TODO NOTE dont ever hardcode styles :pray:
// TODO FINAL OPTIMIZE our shame
// TODO FINAL check if each handle is used
// TODO rewrite string reading
// TODO decide what to do when rentnerend goes to ENDE ENDE (add gameindex and handle it everywhere?)


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
const TIME_UPDATE_INTERVAL_MS = 1_000

let WIDGET_SCOREBOARD_SHOWN = false
let WIDGET_GAMEPLAN_SHOWN = false
let WIDGET_LIVEPLAN_SHOWN = false
let WIDGET_GAMESTART_SHOWN = false
let WIDGET_AD_SHOWN = false

enum CardType { Yellow, Red }
interface Color { r: number, g: number, b: number }

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
	color_left: Color, //Dark
	color_right: Color, //Light
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
		pausestart: number // time_t
	},
	deftime: number,
	games: Game[],
	teams: Team[],
	players: Player[]
}

let md: Matchday = {
	cur: {
		gameindex: 0,
		halftime: false,
		pause: true,
		time: -1,
		pausestart: -1
	},
	deftime: -1,
	games: [],
	teams: [],
	players: []
}

function capitalize(str: string): string {
    if (!str) return str;
    return str[0].toUpperCase() + str.slice(1);
}

function parse_json(json: string){
	const p = JSON.parse(json);

	if(md.deftime === -1) {
		console.log("First JSON Parse")
		md.cur = {
			gameindex: 0,
			halftime: false,
			pause: true,
			time: p.time * (1000 / TIME_UPDATE_INTERVAL_MS),
			pausestart: p.time * (1000 / TIME_UPDATE_INTERVAL_MS)
		}
	}
	md.deftime = p.time * (1000 / TIME_UPDATE_INTERVAL_MS);
	md.games = [];
	md.teams = [];
	md.players = [];
	for (let i = 0; i < p.teams.length; i++) {
		md.players[i*2] = {
			name: p.teams[i].players[0].name,
			role: p.teams[i].players[0].position,
			team_index: i
		};
		md.players[i*2 + 1] = {
				name: p.teams[i].players[1].name,
				role: p.teams[i].players[1].position,
				team_index: i
		};
		md.teams[i] = {
			players_indices: [i*2, i*2 + 1],
			name: p.teams[i].name,
			logo_filename: p.teams[i].logo,
			color_right: color_string_to_color(p.teams[i].color_light),
			color_left: color_string_to_color(p.teams[i].color_dark)
		};
	}
	for (let i = 0; i < p.games.length; i++) {
		md.games[i] = {
			t1_index: md.teams.findIndex(temp => temp.name === p.games[i].team1),
			t2_index: md.teams.findIndex(temp => temp.name === p.games[i].team2),
			halftimescore: {t1: 0, t2: 0},
			score: {t1: 0, t2: 0},
			cards: []
		};
		if(md.games[i].t1_index === -1) console.log(`JSON Misformated: Game ${i} Team 1 not found: ${p.games[i].team1}`);
		if(md.games[i].t2_index === -1) console.log(`JSON Misformated: Game ${i} Team 2 not found: ${p.games[i].team2}`);
		if (p.games[i].score !== undefined) {
			md.games[i].score.t1 = p.games[i].score.team1;
			md.games[i].score.t2 = p.games[i].score.team2;
		}
		if (p.games[i].halftimescore !== undefined) {
			md.games[i].halftimescore.t1 = p.games[i].halftimescore.team1;
			md.games[i].halftimescore.t2 = p.games[i].halftimescore.team2;
		}
		if (p.games[i].cards !== undefined) {
			for(let j=0; j < p.games[i].cards.length; j++){
				md.games[i].cards[j] = {
					card_type: (p.games[i].cards[j].type === "Y") ? CardType.Yellow : CardType.Red,
					player_index: md.players.findIndex(temp => temp.name === capitalize(p.games[i].cards[j].player))
				};
				if(md.games[i].cards[j].player_index === -1)
					console.log(`JSON Misformated: Game ${i} Card ${j} Player not found: ${p.games[i].cards[i].player}`);
			}
		}
	}
}

function color_to_string(c: Color): string {
	return `rgb(${c.r}, ${c.g}, ${c.b})`
}

function color_gradient_to_string(l: Color, r: Color): string {
	return `linear-gradient(90deg, rgb(${l.r}, ${l.g}, ${l.b}) 0%,` +
		`rgb(${r.r}, ${r.g}, ${r.b}) 50%)`
}

function Color_font_contrast(c: Color): string {
	return (Math.max(c.r, c.g, c.b) > 191) ? "black" : "white"
}

//String is formated like this: #2F8AB0
function color_string_to_color(buffer: string): Color {
	return {
		// TODO How to parse char to hexa
		r: parseInt(buffer[1], 16) * 16 + buffer[2],
		g: parseInt(buffer[3], 16) * 16 + buffer[4],
		b: parseInt(buffer[5], 16) * 16 + buffer[6]
	}
}

function write_scoreboard() {
	const game = md.games[md.cur.gameindex]
	const team1 = md.cur.halftime ? md.teams[game.t2_index] : md.teams[game.t1_index]
	const team2 = md.cur.halftime ? md.teams[game.t1_index] : md.teams[game.t2_index]
	scoreboard_t1.innerHTML = team1.name
	scoreboard_t2.innerHTML = team2.name

	scoreboard_score_1.innerHTML = md.cur.halftime ? game.score.t2.toString() : game.score.t1.toString()
	scoreboard_score_2.innerHTML = md.cur.halftime ? game.score.t1.toString() : game.score.t2.toString()

	const t1_col_right = team1.color_right
	const t1_col_left = team1.color_left
	const t2_col_right = team2.color_right
	const t2_col_left = team2.color_left

	//TODO colors
	scoreboard_t1.style.background = Color_gradient_to_string(t1_col_right, t1_col_left)
	scoreboard_t1.style.color = Color_font_contrast(t1_col_left)
	scoreboard_t2.style.background = Color_gradient_to_string(t2_col_left, t2_col_right)
	scoreboard_t2.style.color = Color_font_contrast(t2_col_left)

	update_timer_html()
	update_scoreboard_timer()
}

function write_gameplan() {
	while (gameplan.children.length > 1)
		gameplan.removeChild(gameplan.lastChild!)

	const game_n = md.games.length
	const cur = md.cur.gameindex //TODO Index ab 0 so richtig?

	for (let game_i = 0; game_i < game_n; ++game_i) {
		const teams_1 = md.teams[md.games[game_i].t1_index].name
		const teams_2 = md.teams[md.games[game_i].t2_index].name
		const goals_1 = md.games[game_i].score.t1
		const goals_2 = md.games[game_i].score.t2
		const col_1_right = md.teams[md.games[game_i].t1_index].color_right
		const col_1_left = md.teams[md.games[game_i].t1_index].color_left
		const col_2_right = md.teams[md.games[game_i].t2_index].color_right
		const col_2_left = md.teams[md.games[game_i].t2_index].color_left

		let line = document.createElement("div")
		line.classList.add("line")

		let t1 = document.createElement("div")
		t1.classList.add("bordered", "t1")
		t1.innerHTML = teams_1.toString()
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
	function smoothScrollTo(targetY: number, duration: number = 2_000) {
		const startY = scroller.scrollTop
		const deltaY = targetY - startY
		const startTime = performance.now()

		function step(currentTime: number) {
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

function write_gamestart() {
	gamestart_t1.innerHTML = ""
	gamestart_t2.innerHTML = ""

	const gamei = md.cur.gameindex

	const t1_name = md.teams[md.games[gamei].t1_index].name
	const t2_name = md.teams[md.games[gamei].t2_index].name

	// TODO WIP
	const t1_keeper = md.players[md.teams[md.games[gamei].t1_index].players_indices[0]].name
	const t1_field = md.players[md.teams[md.games[gamei].t1_index].players_indices[1]].name
	const t2_keeper = md.players[md.teams[md.games[gamei].t2_index].players_indices[0]].name
	const t2_field = md.players[md.teams[md.games[gamei].t2_index].players_indices[1]].name

	const t1_col_left = md.teams[md.games[gamei].t1_index].color_left
	const t1_col_right = md.teams[md.games[gamei].t1_index].color_right
	const t2_col_left = md.teams[md.games[gamei].t2_index].color_left
	const t2_col_right = md.teams[md.games[gamei].t2_index].color_right

	const next_t1_name = md.teams[md.games[gamei+1].t1_index].name
	const next_t2_name = md.teams[md.games[gamei+1].t2_index].name
	const next_t1_color_left = md.teams[md.games[gamei+1].t1_index].color_left
	const next_t1_color_right = md.teams[md.games[gamei+1].t1_index].color_right
	const next_t2_color_left = md.teams[md.games[gamei+1].t2_index].color_left
	const next_t2_color_right = md.teams[md.games[gamei+1].t2_index].color_right

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
function write_card(player_index: number, type: CardType) {
	const display_length = 7_000

	card_receiver.innerHTML = md.players[player_index].name.toString() //TODO do we need toString?
	if (type === CardType.Yellow) {
		card_graphic.style.backgroundColor = "#ff0000"
		card_message.innerHTML = "bekommt eine rote Karte"
	} else if (type === CardType.Red) {
		card_graphic.style.backgroundColor = "#ffff00"
		card_message.innerHTML = "bekommt eine gelbe Karte"
	} else {
		console.log("Unknown CardType... exiting")
		return //TODO can we do that and no UI appears?
	}

	md.games[md.cur.gameindex].cards[md.games[md.cur.gameindex].cards.length] = {
		player_index: player_index,
		card_type: type
	}

	setTimeout(() => {
		card.style.opacity = "0"
		setTimeout(() => card.style.display = "none", 500)
	}, display_length)
}

// TODO Does this need to be ?
interface LivetableLine {
	name: string,
	points: number,
	played: number,
	won: number,
	tied: number,
	lost: number,
	goals: number,
	goals_taken: number,
	color_right: number,
	color_left: number
}

function write_livetable() {
	while (livetable.children.length > 2)
		livetable.removeChild(livetable.lastChild!)

	const team_n = md.teams.length
	let teams: LivetableLine[] = []

	for (let i = 0; i < team_n; ++i) {
		console.log("Name: ", md.teams[i].name)
		teams[i] = {
			name: md.teams[i].name.toString(),
			points: ((i, m) => {
				let p: number = 0
				for (let j=0; j <= m.cur.gameindex; j++) { // TODO Count the game right now?
					if (m.games[j].t1_index === i) {
						p += (m.games[j].score.t1 - m.games[j].score.t2 > 0) ? 3 : 0
						p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
					} else if (m.games[j].t2_index === i) {
						p += (m.games[j].score.t1 - m.games[j].score.t2 < 0) ? 3 : 0
						p += (m.games[j].score.t1 - m.games[j].score.t2 === 0) ? 1 : 0
					}
				}
				return p
			}) (i, md),
			played: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++)
					if(md.games[j].t1_index === i || md.games[j].t2_index === i) p++
				return p
			}) (i),
			won: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 > 0) ? 1 : 0
					else if (md.games[j].t2_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 < 0) ? 1 : 0
				}
				return p
			}) (i),
			tied: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 === 0) ? 1 : 0
					else if (md.games[j].t2_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 === 0) ? 1 : 0
				}
				return p
			}) (i),
			lost: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 > 0) ? 0 : 1
					else if (md.games[j].t2_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 < 0) ? 0 : 1
				}
				return p
			}) (i),
			goals: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++) {
					if (md.games[j].t1_index === i) p += md.games[j].score.t1
					else if (md.games[j].t2_index === i) p += md.games[j].score.t2
				}
				return p
			}) (i),
			goals_taken: (i => {
				let p: number = 0
				for (let j=0; j <= md.cur.gameindex; j++) {
					if (md.games[j].t1_index === i) p += md.games[j].score.t2
					else if (md.games[j].t2_index === i) p += md.games[j].score.t1
				}
				return p
			}) (i),
			color_right: md.teams[i].color_right,
			color_left: md.teams[i].color_left,
		}
	}

	teams.sort((a, b) => {
		if (b.points !== a.points) return b.points-a.points;
		if (b.goals-b.goals_taken !== a.goals-a.goals_taken)
			return (b.goals-b.goals_taken) - (a.goals-a.goals_taken)
		if (b.goals !== a.goals) return b.goals-a.goals
		if (b.won !== a.won) return b.won-a.won
		if (b.played !== a.played) return b.played-a.played
		return a.name.localeCompare(b.name)
	});

	for (let team_i = 0; team_i < team_n; ++team_i) {
		const line = document.createElement("div")
		line.classList.add("line")

		const name = document.createElement("div")
		name.innerHTML = teams[team_i].name!.toString()
		name.classList.add("bordered", "name")
		name.style.background = Color_gradient_to_string(teams[team_i].color_right, teams[team_i].color_left)
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

let countdown = 0 //TODO ASK what is this?

// Will this work sub second when it only runs each second? We dont set timer each time we pause/unpause
function async_handle_time() {
	clearInterval(countdown)
	update_timer_html()
	countdown = setInterval(() => {
		update_scoreboard_timer()

		console.log("ASYNC Yeah")
		if (md.cur.pause && (md.cur.pausestart == md.cur.time || md.cur.pausestart == -1)) return
		console.log("still ticking down")
		if (md.cur.pause && md.cur.pausestart > md.cur.time){
			md.cur.time = md.cur.pausestart
			update_timer_html()
			return
		}
		if (md.cur.time <= 1) clearInterval(countdown)

		console.log("tick one down now: ", md.cur.time)
		--md.cur.time

		update_timer_html()
	}, TIME_UPDATE_INTERVAL_MS)
}

function update_scoreboard_timer() {
	if (md.cur.time === -1 || md.deftime === -1) return
	const bar_width = Math.min(100, Math.max(0, (md.cur.time / md.deftime) * 100))
	scoreboard_time_bar.style.width = bar_width + "%"
}

function update_timer_html() {
	const minutes = Math.floor(md.cur.time / 60).toString().padStart(2, "0")
	const seconds = (md.cur.time % 60).toString().padStart(2, "0")
	console.log("update timer: min: " +  minutes +  "sec: " + seconds);
	scoreboard_time_minutes.innerHTML = minutes
	scoreboard_time_seconds.innerHTML = seconds
}

function update_ui() {
	console.log("updating ui")
	if(WIDGET_SCOREBOARD_SHOWN) write_scoreboard()
	if(WIDGET_GAMEPLAN_SHOWN) write_gameplan()
	if(WIDGET_LIVEPLAN_SHOWN) write_livetable()
	if(WIDGET_GAMESTART_SHOWN) write_gamestart()
	if(WIDGET_AD_SHOWN) return//write_ad() //TODO This does not exist, right?
}

socket.onopen = () => {
	console.log("Connected to WebSocket server!")
}

socket.onmessage = (event: MessageEvent) => {
	if (!(event.data instanceof ArrayBuffer)) {
		console.error("Grrrrr, backend didnt senz Binary Data. Fuck off")
		return;
	}

	const data: DataView = new DataView(event.data as ArrayBuffer)
	console.log("Buffer len: ", data.byteLength)

	const mode: number = data.getUint8(0)
	console.log("mode: " + mode)
	switch (mode) {
		case MessageType.WIDGET_SCOREBOARD_SHOW:
			WIDGET_SCOREBOARD_SHOWN = true
			scoreboard.style.display = "inline-flex"
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.opacity = "1", 10)
			write_scoreboard()
			break
		case MessageType.WIDGET_SCOREBOARD_HIDE:
			WIDGET_SCOREBOARD_SHOWN = false
			scoreboard.style.opacity = "0"
			setTimeout(() => scoreboard.style.display = "none", 500)
			break
		case MessageType.WIDGET_GAMEPLAN_SHOW:
			WIDGET_GAMEPLAN_SHOWN = true
			gameplan.style.display = "inline-flex"
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.opacity = "1", 10)
			write_gameplan()
			break
		case MessageType.WIDGET_GAMEPLAN_HIDE:
			WIDGET_GAMEPLAN_SHOWN = false
			gameplan.style.opacity = "0"
			setTimeout(() => gameplan.style.display = "none", 500)
			break
		case MessageType.WIDGET_LIVETABLE_SHOW:
			WIDGET_LIVEPLAN_SHOWN = true
			livetable.style.display = "inline-flex"
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.opacity = "1", 10)
			write_livetable()
			break
		case MessageType.WIDGET_LIVETABLE_HIDE:
			WIDGET_LIVEPLAN_SHOWN = false
			livetable.style.opacity = "0"
			setTimeout(() => livetable.style.display = "none", 500)
			break
		case MessageType.WIDGET_GAMESTART_SHOW:
			WIDGET_GAMESTART_SHOWN = true
			gamestart.style.display = "flex"
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.opacity = "1", 10)
			write_gamestart()
			break
		case MessageType.WIDGET_GAMESTART_HIDE:
			WIDGET_GAMESTART_SHOWN = false
			gamestart.style.opacity = "0"
			setTimeout(() => gamestart.style.display = "none", 500)
			break
		case MessageType.WIDGET_AD_SHOW: // TODO does this work?
			WIDGET_AD_SHOWN = true
			ad.style.display = "block"
			ad.style.opacity = "0"
			setTimeout(() => ad.style.opacity = "1", 10)
			break
		case MessageType.WIDGET_AD_HIDE:
			WIDGET_AD_SHOWN = false
			ad.style.opacity = "0"
			setTimeout(() => ad.style.display = "none", 500)
			break
		case MessageType.T1_SCORE_PLUS:
			md.games[md.cur.gameindex].score.t1++
			update_ui()
			break
		case MessageType.T1_SCORE_MINUS:
			if(md.games[md.cur.gameindex].score.t1 > 0) {
				md.games[md.cur.gameindex].score.t1--
				update_ui()
			}
			break
		case MessageType.T2_SCORE_PLUS:
			md.games[md.cur.gameindex].score.t2++
			update_ui()
			break
		case MessageType.T2_SCORE_MINUS:
			if(md.games[md.cur.gameindex].score.t2 > 0){
				md.games[md.cur.gameindex].score.t2--
				update_ui()
			}
			break
		case MessageType.GAME_NEXT:
			if(md.cur.gameindex < md.games.length-1) {
				md.cur.gameindex++;
				update_ui()
			}
			break
		case MessageType.GAME_PREV:
			if(md.cur.gameindex > 0) {
				md.cur.gameindex--;
				update_ui()
			}
			break
		case MessageType.GAME_SWITCH_SIDES:
			md.cur.halftime = !md.cur.halftime
			update_ui()
			break
		case MessageType.TIME_PLUS_1:
			// TODO Disallow time changes this when we are not paused?
			if(md.cur.pause && md.cur.pausestart != -1) md.cur.time = md.cur.pausestart
			md.cur.pausestart = -1
			md.cur.time += (1000 / TIME_UPDATE_INTERVAL_MS);
			update_ui()
			break
		case MessageType.TIME_MINUS_1:
			if(md.cur.pause && md.cur.pausestart != -1) md.cur.time = md.cur.pausestart
			md.cur.pausestart = -1
			if(md.cur.time > 0) {
				md.cur.time -= (1000 / TIME_UPDATE_INTERVAL_MS)
				update_ui()
			}
			break
		case MessageType.TIME_PLUS_20:
			if(md.cur.pause && md.cur.pausestart != -1) md.cur.time = md.cur.pausestart
			md.cur.pausestart = -1
			md.cur.time += 20 * (1000 / TIME_UPDATE_INTERVAL_MS)
			update_ui()
			break
		case MessageType.TIME_MINUS_20:
			if(md.cur.pause && md.cur.pausestart != -1) md.cur.time = md.cur.pausestart
			md.cur.pausestart = -1
			if(md.cur.time >= 20 * (1000 / TIME_UPDATE_INTERVAL_MS))
				md.cur.time -= 20 * (1000 / TIME_UPDATE_INTERVAL_MS);
			else
				md.cur.time = 0;
			update_ui()
			break
		case MessageType.TIME_TOGGLE_PAUSE:
			console.log("Pausing now")
			md.cur.pause = true
			md.cur.pausestart = data.getUint16(1, true);
			break
		case MessageType.TIME_TOGGLE_UNPAUSE:
			md.cur.pausestart = -1
			md.cur.pause = false
			break
		case MessageType.TIME_RESET:
			md.cur.time = md.deftime
			update_ui()
			break
		case MessageType.YELLOW_CARD:
			card.style.display = "flex"
			card.style.opacity = "0"
			setTimeout(() => card.style.opacity = "1", 10)
			write_card(data.getUint8(1), CardType.Yellow)
			break
		case MessageType.RED_CARD:
			card.style.display = "flex"
			card.style.opacity = "0"
			setTimeout(() => card.style.opacity = "1", 10)
			write_card(data.getUint8(1), CardType.Red)
			break
		case MessageType.DATA_TIME:
			md.cur.pausestart = -1
			console.log("Received DATA time: ", data.getUint16(1, true))
			md.cur.time = data.getUint16(1, true)
			console.log("Written Time: ", md.cur.time)
			console.log(md)
			console.log("Written Time: ", md.cur.time)
			update_ui()
			break;
		case MessageType.DATA_IS_PAUSE:
			console.log("Received DATA is_pause: ", data.getUint8(1) === 1)
			md.cur.pause = data.getUint8(1) === 1
			break;
		case MessageType.DATA_HALFTIME:
			console.log("Received DATA Halftime: ", data.getUint8(1) === 1)
			md.cur.halftime = data.getUint8(1) === 1
			break;
		case MessageType.DATA_GAMEINDEX:
			console.log("Received DATA Gameindex: ", data.getUint8(1))
			md.cur.gameindex = data.getUint8(1)
			break;
		case MessageType.DATA_JSON:
			console.log("Received DATA Gameindex")
			const decoder = new TextDecoder("utf-8")
			const str = decoder.decode(new Uint8Array(data.buffer, data.byteOffset, data.byteLength))
			parse_json(str)
			update_ui()
			break
		//case MessageType.SCOREBOARD_SET_TIMER:
			// TODO This is actually useful, implement in rentnerend
			// TODO make this work
			//scoreboard_set_timer(parseInt(buffer.charCodeAt(1) + buffer.charCodeAt(2)))
		//	break
	}
	console.log("Here is the Matchday again:", md)
}

socket.onerror = (error: Event) => {
	console.error("WebSocket Error: ", error)
}

socket.onclose = () => {
	console.log("WebSocket connection closed!")
}

console.log("Client loaded!")
async_handle_time()

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
