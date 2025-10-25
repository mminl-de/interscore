// TODO NOW implement update_queries

import { MessageType } from "../MessageType.js"
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// MessageType.ts contains only the enum MessageType and is exported, so backend
// and rentnerend can use it as well (through #define magic)

// TODO NOTE dont ever hardcode styles :pray:
// TODO FINAL OPTIMIZE our shame
// TODO FINAL check if each handle is used
// TODO rewrite string reading
// TODO decide what to do when rentnerend goes to ENDE ENDE (add gameindex and handle it everywhere?)


let socket: WebSocket
let reconnect_timer: number | null = null;

const scoreboard = document.querySelector(".scoreboard")! as HTMLElement
const scoreboard_t1 = scoreboard.querySelector(".t1")! as HTMLElement
const scoreboard_t2 = scoreboard.querySelector(".t2")! as HTMLElement
const scoreboard_s1 = scoreboard.querySelector(".s1")!
const scoreboard_s2 = scoreboard.querySelector(".s2")!
const scoreboard_logo_1 = scoreboard.querySelector(".logo-1")! as HTMLImageElement
const scoreboard_logo_2 = scoreboard.querySelector(".logo-2")! as HTMLImageElement
const scoreboard_time_bar = scoreboard.querySelector(".time-container .bar")! as HTMLElement
const scoreboard_time_minutes = scoreboard.querySelector(".time .minutes")!
const scoreboard_time_seconds = scoreboard.querySelector(".time .seconds")!

const gameplan = document.querySelector(".gameplan")! as HTMLElement
const scroller = document.querySelector(".gameplan-container .scroller")! as HTMLElement

const gamestart = document.querySelector(".gamestart")! as HTMLElement
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

type time_t = number

// Important variables for `read_c_string`
const decoder = new TextDecoder("utf-8")
let str_len: number // temporary variable for counting string lengths
let u8_array: Uint8Array

const CARD_SHOW_LENGTH = 7_000
const SCROLL_DURATION = 7_000
const TIME_UPDATE_INTERVAL_MS = 1_000
const TIMEOUT_SHOW = 10
const TIMEOUT_HIDE = 500
const DARKER_COLOR_BIAS: Color = { r: 30, g: 70, b: 100 } // TODO TEST
const COLOR_CONTRAST_THRESHOLD = 191

let shown = {
	scoreboard: false,
	gameplan: false,
	liveplan: false,
	gamestart: false,
	ad: false
}

interface Color { r: number, g: number, b: number }

interface Score { t1: number, t2: number }
interface Card {
	player_index: number,
	card_type: string
}
interface Player {
	name: string,
	team_index: number,
	role: string
}
interface Team {
	name: string,
	players: number[],
	// TODO handle fallback
	logo_path: string, // logo als Bild direkt?
	color_main: Color,
	color_darker: Color
}
interface Game {
	t1_index: number,
	t2_index: number,
	t1_query: GameQuery | null,
	t2_query: GameQuery | null,
	halftime_score: Score,
	score: Score,
	cards: Card[]
}
interface GameQuery {
	set: string,
	group: string,
	key: number
}
interface InputJSON {
	meta: {
		game_len: number,
		game_i: number | null,
		first_halftime: boolean,
		paused: boolean,
		cur_time: number
	},
	teams: {
		name: string,
		logo_path: string,
		color: string,
		players: { name: string, role: string }[]
	}[],
	groups: { [key: string]: string[] },
	games: {
		[1]: {
			name: string | null,
			query: { set: string, group: string, key: number } | null
		},
		[2]: {
			name: string | null,
			query: { set: string, group: string, key: number } | null
		},
		halftime_score: { ["1"]: number, ["2"]: number },
		score: { ["1"]: number, ["2"]: number },
		cards: {
			name: string,
			type: "y" | "r", // TODO NOW TEMPORARY
			reason: string,
			timestamp: time_t
		}[]
	}[]
}
interface Matchday {
	meta: {
		game_len: number,
		game_i: number,
		halftime: boolean,
		paused: boolean,
		cur_time: number,
		pause_start: time_t,
	},
	teams: Team[],
	players: Player[],
	games: Game[],
	groups: Map<string, string[]>
}

let md: Matchday = {
	meta: {
		game_len: -1,
		game_i: 0,
		halftime: false,
		paused: true,
		cur_time: -1,
		pause_start: -1
	},
	games: [],
	teams: [],
	players: [],
	groups: new Map()
}

// Reads the characters of `view` starting with `offset` until the next \0
// delimiter. Returns the characters as a string without the delimiter.
function read_c_string(view: DataView, offset: number): string {
	str_len = 0
	while (view.getUint8(offset + str_len) !== 0) ++str_len
	u8_array = new Uint8Array(view.buffer, view.byteOffset + offset, str_len)
	return decoder.decode(u8_array)
}

function capitalize(str: string): string {
	if (!str) return str
	return str[0].toUpperCase() + str.slice(1)
}

function parse_json(str: string): void {
	const json: InputJSON = JSON.parse(str)

	if (md.meta.game_len === -1) {
		console.log("First JSON Parse")
		md.meta = {
			game_len: json.meta.game_len * (1_000 / TIME_UPDATE_INTERVAL_MS),
			game_i: 0,
			halftime: false,
			paused: true,
			cur_time: json.meta.game_len * (1_000 / TIME_UPDATE_INTERVAL_MS),
			pause_start: json.meta.game_len * (1_000 / TIME_UPDATE_INTERVAL_MS)
		}
	}
	md.games = []
	md.teams = []
	md.players = []
	md.groups = new Map()
	for (let i = 0; i < json.teams.length; i++) {
		md.players[i * 2] = {
			name: json.teams[i].players[0].name,
			role: json.teams[i].players[0].role,
			team_index: i
		}
		md.players[i * 2 + 1] = {
			name: json.teams[i].players[1].name,
			role: json.teams[i].players[1].role,
			team_index: i
		}
		md.teams[i] = {
			players: [i * 2, i * 2 + 1],
			name: json.teams[i].name,
			logo_path: json.teams[i].logo_path,
			color_main: string_to_color(json.teams[i].color),
			color_darker: string_to_darker_color(json.teams[i].color)
		}
		console.log("TODO color lighter:", md.teams[i].color_main)
		console.log("TODO color darker:", md.teams[i].color_darker)
	}
	let find_team_index_cb = (game: any, temp: Team, team_nr: 1 | 2) => {
		if (game[team_nr].name === null) return false
		return temp.name === game[team_nr].name
	}
	for (let game_i = 0; game_i < json.games.length; game_i++) {
		md.games[game_i].t1_index = md.teams.findIndex(temp => find_team_index_cb(json.games[game_i], temp, 1))
		md.games[game_i].t2_index = md.teams.findIndex(temp => find_team_index_cb(json.games[game_i], temp, 2))
		if (md.games[game_i].t1_index === -1 && json.games[game_i][1].query !== null)
			md.games[game_i].t1_query = {
				set: json.games[game_i][1].query?.set as string,
				group: json.games[game_i][1].query?.group as string,
				key: json.games[game_i][1].query?.key as number
			}
		if (md.games[game_i].t2_index === -1 && json.games[game_i][2].query !== null)
			md.games[game_i].t2_query = {
				set: json.games[game_i][2].query?.set as string,
				group: json.games[game_i][2].query?.group as string,
				key: json.games[game_i][2].query?.key as number
			}

		md.games[game_i].halftime_score = { t1: 0, t2: 0 }
		md.games[game_i].score = { t1: 0, t2: 0 }
		md.games[game_i].cards = []

		if (md.games[game_i].t1_index === -1) console.log(`JSON Misformated: Game ${game_i} Team 1 not found: ${json.games[game_i][1]}`)
		if (md.games[game_i].t2_index === -1) console.log(`JSON Misformated: Game ${game_i} Team 2 not found: ${json.games[game_i][2]}`)
		if (json.games[game_i].score !== undefined) {
			md.games[game_i].score.t1 = json.games[game_i].score[1]
			md.games[game_i].score.t2 = json.games[game_i].score[2]
		}
		if (json.games[game_i].halftime_score !== undefined) {
			md.games[game_i].halftime_score.t1 = json.games[game_i].halftime_score[1]
			md.games[game_i].halftime_score.t2 = json.games[game_i].halftime_score[2]
		}
		if (json.games[game_i].cards !== undefined) {
			for (let j = 0; j < json.games[game_i].cards.length; j++) {
				md.games[game_i].cards[j] = {
					card_type: json.games[game_i].cards[j].type,
					player_index: md.players.findIndex(temp => temp.name === capitalize(json.games[game_i].cards[j].name))
				}
				if (md.games[game_i].cards[j].player_index === -1)
					console.log(`JSON Misformated: Game ${game_i} Card ${j} Player not found: ${json.games[game_i].cards[game_i].name}`)
			}
		}
	}
	for (const group_name in json.groups)
		md.groups.set(group_name, structuredClone(json.groups[group_name]))
}

function color_gradient_to_string(l: Color, r: Color): string {
	return `linear-gradient(90deg, rgb(${l.r}, ${l.g}, ${l.b}) 0%,` +
		`rgb(${r.r}, ${r.g}, ${r.b}) 50%)`
}

function color_font_contrast(c: Color): string {
	return (Math.max(c.r, c.g, c.b) > COLOR_CONTRAST_THRESHOLD) ? "black" : "white"
}

// Converts a hexcolor string formatted like #rrggbb into a `Color` instance.
function string_to_color(hexcode: string): Color {
	return {
		r: parseInt(hexcode.slice(1, 3), 16),
		g: parseInt(hexcode.slice(3, 5), 16),
		b: parseInt(hexcode.slice(5, 7), 16)
	}
}

// Computes a darker shade of the described color (#rrggbb) and formats it as a
// `Color` instance.
function string_to_darker_color(hexcode: string): Color {
	return {
		r: Math.max(0, parseInt(hexcode.slice(1, 3), 16) - DARKER_COLOR_BIAS.r),
		g: Math.max(0, parseInt(hexcode.slice(3, 5), 16) - DARKER_COLOR_BIAS.g),
		b: Math.max(0, parseInt(hexcode.slice(5, 7), 16) - DARKER_COLOR_BIAS.b)
	}
}

function query_set_to_string(query: GameQuery): string {
	switch (query.set) {
		case "TEAM":
			return `${query.key + 1}.-stärkstes Team `
		case "WINNER":
			return `Gewinner vom ${query.key + 1}. Spiel`
		case "LOSER":
			return `Verlierer vom ${query.key + 1}. Spiel`
		case "GROUP":
			return `${query.key + 1}. aus Gruppe ${query.group}`
		default:
			return query.set + query.key + query.group // actually unreachable
	}
}

async function file_exists(url: string): Promise<boolean> {
	try {
		const response = await fetch(url, { method: "HEAD" })
		return response.ok
	} catch (err) {
		return false
	}
}

function write_scoreboard() {
	const fallback_team: Team = {
		name: "",
		players: [],
		logo_path: "../assets/fallback.png",
		color_main: { r: 255, g: 255, b: 255 },
		color_darker: { r: 100, g: 100, b: 100 }
	}

	// TODO TEST
	const game = md.games[md.meta.game_i]
	const team_left = (() => {
		const query = md.meta.halftime ? game.t2_query : game.t1_query
		if (query === null)
			return md.meta.halftime ? md.teams[game.t2_index] : md.teams[game.t1_index]

		let result = fallback_team
		result.name = query_set_to_string(query)
		return result
	})()
	const team_right = (() => {
		const query = md.meta.halftime ? game.t1_query : game.t2_query
		if (query === null)
			return md.meta.halftime ? md.teams[game.t1_index] : md.teams[game.t2_index]

		let result = fallback_team
		result.name = query_set_to_string(query)
		return result
	})()

	scoreboard_t1.innerHTML = team_left.name
	scoreboard_t2.innerHTML = team_right.name

	file_exists("../" + team_left.logo_path).then((exists: boolean) => {
		if (exists) scoreboard_logo_1.src = "../" + team_left.logo_path
		else scoreboard_logo_1.src = "../assets/fallback.png"
	})
	file_exists("../" + team_right.logo_path).then((exists: boolean) => {
		if (exists) scoreboard_logo_2.src = "../" + team_right.logo_path
		else scoreboard_logo_2.src = "../assets/fallback.png"
	})

	scoreboard_s1.innerHTML = md.meta.halftime ? game.score.t2.toString() : game.score.t1.toString()
	scoreboard_s2.innerHTML = md.meta.halftime ? game.score.t1.toString() : game.score.t2.toString()

	// TODO NOW this can become a problem for queried teams
	const t1_col_main = team_left.color_main
	const t1_col_darker = team_left.color_darker
	const t2_col_main = team_right.color_main
	const t2_col_darker = team_right.color_darker

	scoreboard_t1.style.background = color_gradient_to_string(t1_col_main, t1_col_darker)
	scoreboard_t1.style.color = color_font_contrast(t1_col_darker)
	scoreboard_t2.style.background = color_gradient_to_string(t2_col_darker, t2_col_main)
	scoreboard_t2.style.color = color_font_contrast(t2_col_darker)

	update_timer_html()
	update_scoreboard_timer()
}

function write_gameplan() {
	while (gameplan.children.length > 1)
	gameplan.removeChild(gameplan.lastChild!)

	const game_n = md.games.length
	const cur = md.meta.game_i //TODO Index ab 0 so richtig?

	for (let game_i = 0; game_i < game_n; ++game_i) {
		const teams_1 = md.teams[md.games[game_i].t1_index].name
		const teams_2 = md.teams[md.games[game_i].t2_index].name
		const goals_1 = md.games[game_i].score.t1
		const goals_2 = md.games[game_i].score.t2

		const col_1_right = md.teams[md.games[game_i].t1_index].color_main
		const col_1_left = md.teams[md.games[game_i].t1_index].color_darker
		const col_2_right = md.teams[md.games[game_i].t2_index].color_main
		const col_2_left = md.teams[md.games[game_i].t2_index].color_darker

		let line = document.createElement("div")
		line.classList.add("line")

		let t1 = document.createElement("div")
		t1.classList.add("bordered", "t1")
		t1.innerHTML = teams_1.toString()
		t1.style.background = color_gradient_to_string(col_1_right, col_1_left)
		t1.style.color = color_font_contrast(col_1_right)
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
		t2.style.background = color_gradient_to_string(col_2_right, col_2_left)
		t1.style.color = color_font_contrast(col_2_right)
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
			}, SCROLL_DURATION + 2_000) // duration + delay
		}, 2_000)
	}
}

function write_gamestart() {
	gamestart_t1.innerHTML = ""
	gamestart_t2.innerHTML = ""

	const gamei = md.meta.game_i

	const t1_name = md.teams[md.games[gamei].t1_index].name
	const t2_name = md.teams[md.games[gamei].t2_index].name

	const t1_keeper = md.players[md.teams[md.games[gamei].t1_index].players[0]].name
	const t1_field = md.players[md.teams[md.games[gamei].t1_index].players[1]].name
	const t2_keeper = md.players[md.teams[md.games[gamei].t2_index].players[0]].name
	const t2_field = md.players[md.teams[md.games[gamei].t2_index].players[1]].name

	const t1_col_left = md.teams[md.games[gamei].t1_index].color_darker
	const t1_col_right = md.teams[md.games[gamei].t1_index].color_main
	const t2_col_left = md.teams[md.games[gamei].t2_index].color_darker
	const t2_col_right = md.teams[md.games[gamei].t2_index].color_main

	const next_t1_name = md.teams[md.games[gamei+1].t1_index].name
	const next_t2_name = md.teams[md.games[gamei+1].t2_index].name
	const next_t1_color_left = md.teams[md.games[gamei+1].t1_index].color_darker
	const next_t1_color_right = md.teams[md.games[gamei+1].t1_index].color_main
	const next_t2_color_left = md.teams[md.games[gamei+1].t2_index].color_darker
	const next_t2_color_right = md.teams[md.games[gamei+1].t2_index].color_main

	const t1_el = document.createElement("div")
	t1_el.classList.add("team")

	const t1_name_el = document.createElement("div")
	t1_name_el.classList.add("bordered")
	t1_name_el.style.fontSize = "60px"
	t1_name_el.style.background = color_gradient_to_string(t1_col_left, t1_col_right)
	t1_name_el.style.color = color_font_contrast(t1_col_right)
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
	t2_name_el.style.fontSize = "60px"
	t2_name_el.style.background = color_gradient_to_string(t2_col_left, t2_col_right)
	t2_name_el.style.color = color_font_contrast(t2_col_left)
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
				color_gradient_to_string(next_t1_color_left, next_t1_color_right)
			gamestart_next_t2.innerHTML = next_t2_name
			gamestart_next_t2.style.background =
				color_gradient_to_string(next_t2_color_left, next_t2_color_right)
		}
}

// TODO refactor as handler function for receiving a card, also adding it to the Matchday
function write_card(player_index: number, type: string) {
	card_receiver.innerHTML = md.players[player_index].name.toString() //TODO do we need toString?
	// TODO make the card system more flexible
	switch (type) {
		case "Y":
			card_graphic.style.backgroundColor = "#ffff00"
			card_message.innerHTML = "bekommt eine gelbe Karte"
			break
		case "R":
			card_graphic.style.backgroundColor = "#ff0000"
			card_message.innerHTML = "bekommt eine rote Karte"
			break
		default:
			console.error("Unknown CardType... exiting")
			return // TODO can we do that and no UI appears?
	}

	md.games[md.meta.game_i].cards[md.games[md.meta.game_i].cards.length] = {
		player_index: player_index,
		card_type: type
	}

	setTimeout(() => {
		card.style.opacity = "0"
		setTimeout(() => card.style.display = "none", 500)
	}, CARD_SHOW_LENGTH)
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
	color_right: Color,
	color_left: Color
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
				for (let j = 0; j <= m.meta.game_i; j++) { // TODO Count the game right now?
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
				for (let j = 0; j <= md.meta.game_i; j++)
				if (md.games[j].t1_index === i || md.games[j].t2_index === i) p++
				return p
			}) (i),
			won: (i => {
				let p: number = 0
				for (let j = 0; j <= md.meta.game_i; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 > 0) ? 1 : 0
						else if (md.games[j].t2_index === i)
							p += (md.games[j].score.t1 - md.games[j].score.t2 < 0) ? 1 : 0
				}
				return p
			}) (i),
			tied: (i => {
				let p: number = 0
				for (let j = 0; j <= md.meta.game_i; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 === 0) ? 1 : 0
						else if (md.games[j].t2_index === i)
							p += (md.games[j].score.t1 - md.games[j].score.t2 === 0) ? 1 : 0
				}
				return p
			}) (i),
			lost: (i => {
				let p: number = 0
				for (let j = 0; j <= md.meta.game_i; j++) {
					if (md.games[j].t1_index === i)
						p += (md.games[j].score.t1 - md.games[j].score.t2 > 0) ? 0 : 1
						else if (md.games[j].t2_index === i)
							p += (md.games[j].score.t1 - md.games[j].score.t2 < 0) ? 0 : 1
				}
				return p
			}) (i),
			goals: (i => {
				let p: number = 0
				for (let j = 0; j <= md.meta.game_i; j++) {
					if (md.games[j].t1_index === i) p += md.games[j].score.t1
						else if (md.games[j].t2_index === i) p += md.games[j].score.t2
				}
				return p
			}) (i),
			goals_taken: (i => {
				let p: number = 0
				for (let j = 0; j <= md.meta.game_i; j++) {
					if (md.games[j].t1_index === i) p += md.games[j].score.t2
						else if (md.games[j].t2_index === i) p += md.games[j].score.t1
				}
				return p
			}) (i),
			color_right: md.teams[i].color_main,
			color_left: md.teams[i].color_darker,
		}
	}

	teams.sort((a, b) => {
		if (b.points !== a.points) return b.points - a.points
		if (b.goals - b.goals_taken !== a.goals - a.goals_taken)
			return (b.goals - b.goals_taken) - (a.goals - a.goals_taken)
		if (b.goals !== a.goals) return b.goals - a.goals
		if (b.won !== a.won) return b.won - a.won
		if (b.played !== a.played) return b.played - a.played
		return a.name.localeCompare(b.name)
	})

	for (let team_i = 0; team_i < team_n; ++team_i) {
		const line = document.createElement("div")
		line.classList.add("line")

		const name = document.createElement("div")
		name.innerHTML = teams[team_i].name!.toString()
		name.classList.add("bordered", "name")
		name.style.background = color_gradient_to_string(teams[team_i].color_right, teams[team_i].color_left)
		name.style.color = color_font_contrast(teams[team_i].color_right!)
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

		if (md.meta.paused && (md.meta.pause_start == md.meta.cur_time || md.meta.pause_start == -1)) return
		if (md.meta.paused && md.meta.pause_start > md.meta.cur_time) {
			md.meta.cur_time = md.meta.pause_start
			update_timer_html()
			return
		}
		if (md.meta.cur_time <= 1) clearInterval(countdown)

		console.log("tick one down now: ", md.meta.cur_time)
		--md.meta.cur_time

		update_timer_html()
	}, TIME_UPDATE_INTERVAL_MS)
}

function update_scoreboard_timer() {
	if (md.meta.cur_time === -1 || md.meta.game_len === -1) return
	const bar_width = Math.min(100, Math.max(0, (md.meta.cur_time / md.meta.game_len) * 100))
	scoreboard_time_bar.style.width = bar_width + "%"
}

function update_timer_html() {
	const minutes = Math.floor(md.meta.cur_time / 60).toString().padStart(2, "0")
	const seconds = (md.meta.cur_time % 60).toString().padStart(2, "0")
	console.log("update timer: min: " +  minutes +  "sec: " + seconds)
	scoreboard_time_minutes.innerHTML = minutes
	scoreboard_time_seconds.innerHTML = seconds
}

function update_ui() {
	console.log("updating ui")
	if (shown.scoreboard) write_scoreboard()
	if (shown.gameplan) write_gameplan()
	if (shown.liveplan) write_livetable()
	if (shown.gamestart) write_gamestart()
	if (shown.ad) return //write_ad() //TODO This does not exist, right?
}

function connect() {
	socket = new WebSocket("ws://0.0.0.0:8081?client=frontend", "interscore")
	socket.binaryType = "arraybuffer"

	socket.onopen = () => console.log("Connected to WebSocket server!")

	socket.onmessage = (event: MessageEvent) => {
		if (!(event.data instanceof ArrayBuffer)) {
			console.error("The backend didn't send proper binary data. There's nothing we can do...")
			return
		}

		const dv = new DataView(event.data as ArrayBuffer)
		const mode = dv.getUint8(0)

		switch (mode) {
			case MessageType.WIDGET_SCOREBOARD_SHOW:
				shown.scoreboard = true
				scoreboard.style.display = "inline-flex"
				scoreboard.style.opacity = "0" // TODO READ why is this line present on both show and hide
				setTimeout(() => scoreboard.style.opacity = "1", TIMEOUT_SHOW)
				write_scoreboard()
				break
			case MessageType.WIDGET_SCOREBOARD_HIDE:
				shown.scoreboard = false
				scoreboard.style.opacity = "0"
				setTimeout(() => scoreboard.style.display = "none", TIMEOUT_HIDE)
				break
			case MessageType.WIDGET_GAMEPLAN_SHOW:
				shown.gameplan = true
				gameplan.style.display = "inline-flex"
				gameplan.style.opacity = "0"
				setTimeout(() => gameplan.style.opacity = "1", TIMEOUT_SHOW)
				write_gameplan()
				break
			case MessageType.WIDGET_GAMEPLAN_HIDE:
				shown.gameplan = false
				gameplan.style.opacity = "0"
				setTimeout(() => gameplan.style.display = "none", TIMEOUT_HIDE)
				break
			case MessageType.WIDGET_LIVETABLE_SHOW:
				shown.liveplan = true
				livetable.style.display = "inline-flex"
				livetable.style.opacity = "0"
				setTimeout(() => livetable.style.opacity = "1", TIMEOUT_SHOW)
				write_livetable()
				break
			case MessageType.WIDGET_LIVETABLE_HIDE:
				shown.liveplan = false
				livetable.style.opacity = "0"
				setTimeout(() => livetable.style.display = "none", TIMEOUT_HIDE)
				break
			case MessageType.WIDGET_GAMESTART_SHOW:
				shown.gamestart = true
				gamestart.style.display = "flex"
				gamestart.style.opacity = "0"
				setTimeout(() => gamestart.style.opacity = "1", TIMEOUT_SHOW)
				write_gamestart()
				break
			case MessageType.WIDGET_GAMESTART_HIDE:
				shown.gamestart = false
				gamestart.style.opacity = "0"
				setTimeout(() => gamestart.style.display = "none", TIMEOUT_HIDE)
				break
			case MessageType.WIDGET_AD_SHOW: // TODO does this work?
				shown.ad = true
				ad.style.display = "block"
				ad.style.opacity = "0"
				setTimeout(() => ad.style.opacity = "1", TIMEOUT_SHOW)
				break
			case MessageType.WIDGET_AD_HIDE:
				shown.ad = false
				ad.style.opacity = "0"
				setTimeout(() => ad.style.display = "none", TIMEOUT_HIDE)
				break
			case MessageType.T1_SCORE_PLUS:
				md.games[md.meta.game_i].score.t1++
				update_ui()
				break
			case MessageType.T1_SCORE_MINUS:
				if (md.games[md.meta.game_i].score.t1 > 0) {
					md.games[md.meta.game_i].score.t1--
					update_ui()
				}
				break
			case MessageType.T2_SCORE_PLUS:
				md.games[md.meta.game_i].score.t2++
				update_ui()
				break
			case MessageType.T2_SCORE_MINUS:
				if (md.games[md.meta.game_i].score.t2 > 0) {
					md.games[md.meta.game_i].score.t2--
					update_ui()
				}
				break
			case MessageType.GAME_NEXT:
				// TODO NOW update queries
				if (md.meta.game_i < md.games.length - 1) {
					md.meta.game_i++
					update_ui()
				}
				break
			case MessageType.GAME_PREV:
				// TODO NOW update queries
				if (md.meta.game_i > 0) {
					md.meta.game_i--
					update_ui()
				}
				break
			case MessageType.GAME_SWITCH_SIDES:
				// TODO ASK should this signal be independent of the halftime signal?
				md.meta.halftime = !md.meta.halftime
				update_ui()
				break
			case MessageType.TIME_PLUS_1:
				// TODO Disallow time changes this when we are not paused?
				if (md.meta.paused && md.meta.pause_start != -1) md.meta.cur_time = md.meta.pause_start
				md.meta.pause_start = -1
				md.meta.cur_time += (1_000 / TIME_UPDATE_INTERVAL_MS)
				update_ui()
				break
			case MessageType.TIME_MINUS_1:
				if (md.meta.paused && md.meta.pause_start != -1) md.meta.cur_time = md.meta.pause_start
				md.meta.pause_start = -1
				if (md.meta.cur_time > 0) {
					md.meta.cur_time -= (1_000 / TIME_UPDATE_INTERVAL_MS)
					update_ui()
				}
				break
			case MessageType.TIME_PLUS_20:
				if (md.meta.paused && md.meta.pause_start != -1) md.meta.cur_time = md.meta.pause_start
				md.meta.pause_start = -1
				md.meta.cur_time += 20 * (1_000 / TIME_UPDATE_INTERVAL_MS)
				update_ui()
				break
			case MessageType.TIME_MINUS_20:
				if (md.meta.paused && md.meta.pause_start != -1) md.meta.cur_time = md.meta.pause_start
				md.meta.pause_start = -1
				if (md.meta.cur_time >= 20 * (1_000 / TIME_UPDATE_INTERVAL_MS))
					md.meta.cur_time -= 20 * (1_000 / TIME_UPDATE_INTERVAL_MS)
					else
					md.meta.cur_time = 0
				update_ui()
				break
			case MessageType.TIME_TOGGLE_PAUSE:
				console.log("Pausing now")
				md.meta.paused = true
				md.meta.pause_start = dv.getUint16(1, true) // TODO ASK why offset 1
				break
			case MessageType.TIME_TOGGLE_UNPAUSE:
				// ^ TODO ASK why
				md.meta.pause_start = -1
				md.meta.paused = false
				break
			case MessageType.TIME_RESET:
				md.meta.cur_time = md.meta.game_len
				update_ui()
				break
			case MessageType.PENALTY:
				card.style.display = "flex"
				card.style.opacity = "0"
				setTimeout(() => card.style.opacity = "1", 10)
				write_card(dv.getUint8(1), read_c_string(dv, 1)) // TODO ASK why this offset
				break
			case MessageType.DATA_TIME:
				md.meta.pause_start = -1
				console.log("Received DATA time: ", dv.getUint16(1, true)) // TODO ASK why this offset
				md.meta.cur_time = dv.getUint16(1, true) // TODO ASK why this offset
				update_ui()
				break
			case MessageType.DATA_IS_PAUSE:
				console.log("Received DATA is_pause: ", dv.getUint8(1) === 1) // TODO ASK just why this offset
				md.meta.paused = dv.getUint8(1) === 1
				break
			case MessageType.DATA_HALFTIME:
				console.log("Received DATA Halftime: ", dv.getUint8(1) === 1)
				md.meta.halftime = dv.getUint8(1) === 1
				break
			case MessageType.DATA_GAMEINDEX:
				// ^ TODO CONSIDER RENAME
				console.log("Received DATA Gameindex: ", dv.getUint8(1))
				md.meta.game_i = dv.getUint8(1)
				break
			case MessageType.DATA_JSON:
				// ^ TODO CONSIDER RENAME
				console.log("Received DATA Gameindex")
				const decoder = new TextDecoder("utf-8")
				const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset, dv.byteLength))
				parse_json(str)
				update_ui()
				break
			//case MessageType.SCOREBOARD_SET_TIMER:
			// TODO This is actually useful, implement in rentnerend
			// TODO make this work
			//scoreboard_set_timer(parseInt(buffer.charCodeAt(1) + buffer.charCodeAt(2)))
			//	break
		}
	}

	socket.onerror = (error: Event) => console.error("WebSocket Error: ", error)
	socket.onclose = () => {
		console.log("WebSocket connection closed! Reconnecting in 3s");
		reconnect_timer = window.setTimeout(connect, 3000);
	}
}

connect()
async_handle_time()
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
