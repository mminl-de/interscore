// TODO NOW implement update_queries
import { z } from "zod"; // TODO CONSIDER

import { MessageType } from "./MessageType.ts";
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// MessageType.ts contains only the enum MessageType and is exported, so backend
// and rentnerend can use it as well (through #define magic)

// TODO NOTE dont ever hardcode styles :pray:
// TODO FINAL check if each handle is used
// TODO rewrite string reading
// TODO decide what to do when rentnerend goes to ENDE ENDE (add gameindex and handle it everywhere?)
// TODO FINAL OPTIMIZE our shame

let socket: WebSocket;
let reconnect_timer: number | null = null;

const scoreboard = document.querySelector(".scoreboard")! as HTMLElement;
const scoreboard_t1 = scoreboard.querySelector(".t1")! as HTMLElement;
const scoreboard_t2 = scoreboard.querySelector(".t2")! as HTMLElement;
const scoreboard_s1 = scoreboard.querySelector(".s1")!;
const scoreboard_s2 = scoreboard.querySelector(".s2")!;
const scoreboard_logo_1 = scoreboard.querySelector(".logo-1")! as HTMLImageElement;
const scoreboard_logo_2 = scoreboard.querySelector(".logo-2")! as HTMLImageElement;
const scoreboard_time_bar = scoreboard.querySelector(".time-container .bar")! as HTMLElement;
const scoreboard_time_minutes = scoreboard.querySelector(".time .minutes")!;
const scoreboard_time_seconds = scoreboard.querySelector(".time .seconds")!;

const gameplan = document.querySelector(".gameplan")! as HTMLElement;
const scroller = document.querySelector(".gameplan-container .scroller")! as HTMLElement;

const gamestart = document.querySelector(".gamestart")! as HTMLElement;
const gamestart_t1 = gamestart.querySelector(".t1")! as HTMLElement;
const gamestart_t2 = gamestart.querySelector(".t2")! as HTMLElement;
const gamestart_next = gamestart.querySelector(".next")! as HTMLElement;
const gamestart_next_t1 = gamestart_next.querySelector(".t1")! as HTMLElement;
const gamestart_next_t2 = gamestart_next.querySelector(".t2")! as HTMLElement;

const card = document.querySelector(".card")! as HTMLElement;
const card_graphic = card.querySelector(".card-graphic")! as HTMLElement;
const card_receiver = card.querySelector(".card-receiver")!;
const card_message = card.querySelector(".card-message")!;

const ad = document.querySelector(".ad")! as HTMLElement;

const livetable = document.querySelector(".livetable")! as HTMLElement;

// Important variables for `read_c_string`
const decoder = new TextDecoder("utf-8");

const SCROLL_DURATION = 7_000;
const TIME_UPDATE_INTERVAL_MS = 1_000;
const TIMEOUT_SHOW = 200;
const TIMEOUT_HIDE = 500;
const DARKER_COLOR_BIAS: Color = { r: 30, g: 70, b: 100 }; // TODO TEST

// TODO FINAL CONSIDER bitmap lmao
let shown = {
	scoreboard: false,
	gameplan: false,
	livetable: false,
	gamestart: false,
	ad: false
};

type Color = { r: number, g: number, b: number };

// TODO CONSIDER should you put z.<datatype>() in a constant to avoid re-eval?
const PenaltySchema = z.object({
	shooting: z.object({
		team: z.number(),
		player: z.number(),
	}),
});
const GamePartTimedSchema = z.object({
	type: z.literal("timed"),
	name: z.string(),
	length: z.number(),
	repeat: z.boolean().default(false),
	decider: z.boolean().default(false),
	sides_inverted: z.boolean().default(false),
});
const GamePartFormatSchema = z.object({
	type: z.literal("format"),
	format: z.string(),
	repeat: z.boolean().default(false),
	decider: z.boolean().default(false),
	sides_inverted: z.boolean().default(false),
});
const GamePartPenaltySchema = z.object({
	type: z.literal("penalty"),
	name: z.string(),
	penalty: PenaltySchema,
	repeat: z.boolean().default(false),
	decider: z.boolean().default(false),
	sides_inverted: z.boolean().default(false),
});
const GamePartSchema = z.discriminatedUnion("type", [
	GamePartTimedSchema,
	GamePartFormatSchema,
	GamePartPenaltySchema
]);

export const PlayerSchema = z.object({
	name: z.string(),
	role: z.string(),
});

export const TeamSchema = z.object({
	name: z.string(),
	logo_uri: z.string(),
	color: z.string(),
	players: z.array(PlayerSchema),
});

export const GroupSchema = z.object({
	name: z.string(),
	members: z.array(z.string()),
});

const GameQueryGroupPlaceSchema = z.object({
	type: z.literal("groupPlace"),
	group: z.string(),
	place: z.number(),
});

const GameQueryGameWinnerSchema = z.object({
	type: z.literal("gameWinner"),
	gameIndex: z.number(),
});

const GameQueryGameLoserSchema = z.object({
	type: z.literal("gameLoser"),
	gameIndex: z.number(),
});

export const GameQuerySchema = z.discriminatedUnion("type", [
	GameQueryGroupPlaceSchema,
	GameQueryGameWinnerSchema,
	GameQueryGameLoserSchema,
]);

export const MissingInfoSchema = z.object({
	reason: z.string(),
});

const GameTeamSlotByNameSchema = z.object({
	type: z.literal("byName"),
	name: z.string(),
	missing: MissingInfoSchema.nullable().optional(),
});

const GameTeamSlotByQuerySchema = z.object({
	type: z.literal("byQuery"),
	query: GameQuerySchema,
	missing: MissingInfoSchema.nullable().optional(),
});

const GameTeamSlotByQueryResolvedSchema = z.object({
	type: z.literal("byQueryResolved"),
	name: z.string(),
	q: GameTeamSlotByQuerySchema,
});

export const GameTeamSlotSchema = z.discriminatedUnion("type", [
	GameTeamSlotByNameSchema,
	GameTeamSlotByQuerySchema,
	GameTeamSlotByQueryResolvedSchema,
]);

export const GameActionPlayerInvolvedSchema = z.object({
	name: z.string(),
	role: z.string(),
});

export const GameFormatSchema = z.object({
	name: z.string(),
	decider: z.boolean().default(false),
});

const GameActionBaseSchema = z.object({
	id: z.number(),
	time_game: z.number().nullable().default(null),
	timespan_game: z.number().nullable().default(null),
	time_unix: z.number().nullable().default(null),
	timespan_unix: z.number().nullable().default(null),
	players_involved: z.array(GameActionPlayerInvolvedSchema).nullable().default(null),
	description: z.string().nullable().default(null),
	done: z.boolean().default(true),
});

const GameActionGoalSchema = GameActionBaseSchema.extend({
	type: z.literal("goal"),
	change: z.object({
		type: z.literal("score"),
		score: z.object({
			'1': z.number().default(0),
			'2': z.number().default(0),
		}),
	}),
	triggers_action: z.number().nullable().default(null),
});

const GameActionFoulSchema = GameActionBaseSchema.extend({
	type: z.literal("foul"),
	triggers_action: z.number().nullable().default(null),
});

const GameActionPenaltySchema = GameActionBaseSchema.extend({
	type: z.literal("penalty"),
	// No 'triggers_action' field here, just using base fields
});

const GameActionOutballSchema = GameActionBaseSchema.extend({
	type: z.literal("outball"),
	team: z.number().refine(n => n === 1 || n === 2), // Ensure team is 1 or 2
});

export const GameActionSchema = z.discriminatedUnion("type", [
	GameActionGoalSchema,
	GameActionFoulSchema,
	GameActionPenaltySchema,
	GameActionOutballSchema,
]);

const FormatSchema  = z.object({
	name: z.string(),
	gameparts: z.array(GamePartSchema)
});

const MetaSchema = z.object({
	game_i: z.number().default(0),
	cur_gamepart: z.number().default(0),
	sides_inverted: z.boolean().default(false),
	paused: z.boolean().default(true),
	cur_time: z.number().default(0),
	formats: z.array(FormatSchema)
});

export const GameSchema = z.object({
	name: z.string(),
	'1': GameTeamSlotSchema,
	'2': GameTeamSlotSchema,
	groups: z.array(z.string()).default([]),
	format: GameFormatSchema,
	decider: z.boolean().default(false),
	actions: z.array(z.any()).default([]),
});

const MatchdaySchema = z.object({
	meta: MetaSchema,
	teams: z.array(TeamSchema),
	groups: z.array(GroupSchema),
	games: z.array(GameSchema)
});

export type Matchday = z.infer<typeof MatchdaySchema>;
export type Meta = z.infer<typeof MetaSchema>;
export type Team = z.infer<typeof TeamSchema>;
export type Group = z.infer<typeof GroupSchema>;
export type Game = z.infer<typeof GameSchema>;
export type Format = z.infer<typeof FormatSchema>;
export type GamePart = z.infer<typeof GamePartSchema>;
export type GameTeamSlot = z.infer<typeof GameTeamSlotSchema>;
export type GameAction = z.infer<typeof GameActionSchema>;
export type GameQuery = z.infer<typeof GameQuerySchema>;

let md: Matchday = {
	meta: {
		game_i: 0,
		paused: true,
		cur_time: 0,
		cur_gamepart: 0,
		formats: [],
		sides_inverted: false
	},
	games: [],
	groups: [],
	teams: []
};

function cur_game(): (Game | null) {
	return md.games[md.meta.game_i];
}

function cur_format(): (Format | null) {
	return (md.meta.formats.find((f) => f.name === cur_game()?.format.name)) ?? null;
}

function cur_gamepart(): (GamePart | null) {
	return cur_format()?.gameparts[md.meta.cur_gamepart] ?? null;
}

function resolve_GameTeamSlot(gts: GameTeamSlot): Team | null {
	const team_name = (() => {
		switch (gts.type) {
			case "byName": return gts.name
			case "byQuery": return null;
			case "byQueryResolved": return gts.name;
		}
	})();

	return md.teams.find(g => g.name == team_name) ?? null;
}

// team=0 für Team 1, team=1 für Team 2
function get_scores(g: Game): [scoreT1: number, scoreT2: number] {
	console.log(`getting Score for Game:` + JSON.stringify(g));
	return g.actions.reduce<[number, number]>((acc: [t1: number,t2: number], a: GameAction) => {
		if (a.type === "goal") return [acc[0] + (a.change.score['1'] || 0), acc[1] + (a.change.score['2'] || 0)];
		else return acc;
	}, [0, 0]);
}

// Returns Teams in correct left/right direction (as the scoreboard would write it)
function get_teams(g: Game): [t1: Team | null, t2: Team | null] {
	const team_left = resolve_GameTeamSlot(g[1]);
	const team_right = resolve_GameTeamSlot(g[2]);
	return md.meta.sides_inverted ? [team_right, team_left] : [team_left, team_right];
}

function json_parse(s: string): Matchday {
	return MatchdaySchema.parse(JSON.parse(s));
}

// Reads the characters of `view` starting with `offset` until the next \0
// delimiter. Returns the characters as a string without the delimiter.
// let str_len: number // temporary variable for counting string lengths
//function read_c_string(view: DataView, offset: number): string {
//	str_len = 0
//	while (view.getUint8(offset + str_len) !== 0) ++str_len
//	const u8_array = new Uint8Array(view.buffer, view.byteOffset + offset, str_len)
//	return decoder.decode(u8_array)
//}

//function capitalize(str: string): string {
//	if (!str) return str
//	return str[0].toUpperCase() + str.slice(1)
//}

function gradient2str(l: Color, r: Color): string {
	return `linear-gradient(90deg, rgb(${l.r}, ${l.g}, ${l.b}) 0%,` +
		`rgb(${r.r}, ${r.g}, ${r.b}) 50%)`;
}

//function color_font_contrast(c: Color): string {
//	return (Math.max(c.r, c.g, c.b) > COLOR_CONTRAST_THRESHOLD) ? "black" : "white"
//}

// Inspired by the WCAG contrast ratio method
function color_font_contrast(c: Color): string {
	// Convert sRGB to linear
	const to_linear = (c: number) => {
		c /= 255
		return c <= 0.03928
			? c / 12.92
			: Math.pow((c + 0.055) / 1.055, 2.4)
	};

	// Relative luminance
	const L =
		0.2126 * to_linear(c.r) +
			0.7152 * to_linear(c.g) +
			0.0722 * to_linear(c.b);

	// Contrast ratios vs black and white
	const contrast_black = (L + 0.05) / 0.05;
	const contrast_white = (1.05) / (L + 0.05);

	return contrast_white > contrast_black ? "white" : "black";
}

// Converts a hexcolor string formatted like #rrggbb into a `Color` instance.
function str2col(hexcode: string): Color {
	return {
		r: parseInt(hexcode.slice(1, 3), 16),
		g: parseInt(hexcode.slice(3, 5), 16),
		b: parseInt(hexcode.slice(5, 7), 16)
	};
}

// Computes a darker shade of the described color (#rrggbb) and formats it as a
// `Color` instance.
function str2coldark(hexcode: string): Color {
	return {
		r: Math.max(0, parseInt(hexcode.slice(1, 3), 16) - DARKER_COLOR_BIAS.r),
		g: Math.max(0, parseInt(hexcode.slice(3, 5), 16) - DARKER_COLOR_BIAS.g),
		b: Math.max(0, parseInt(hexcode.slice(5, 7), 16) - DARKER_COLOR_BIAS.b)
	};
}

function query_set_to_string(query: GameQuery): string {
	switch (query.type) {
		//case "TEAM":
		//	return `${query.key + 1}.-stärkstes Team `
		case "gameWinner":
			return `Gewinner vom ${query.gameIndex + 1}. Spiel`
		case "gameLoser":
			return `Verlierer vom ${query.gameIndex + 1}. Spiel`
		case "groupPlace":
			return `${query.place + 1}. aus Gruppe ${query.group}`
	}
}

// TODO CONSIDER REMOVE
//async function file_exists(url: string): Promise<boolean> {
//	try {
//		const response = await fetch(url, { method: "HEAD" })
//		return response.ok
//	} catch (err) {
//		return false
//	}
//}

function write_scoreboard() {
	const game = md.games[md.meta.game_i];
	//console.log(md.meta.game_i);
	console.log(md);

	const teams = get_teams(game);

	console.log(teams);
	console.log(`TEAM 1: ${teams[0]?.name}`);
	console.log(`TEAM 2: ${teams[1]?.name}`);
	scoreboard_t1.innerHTML = teams[0]?.name ?? '[???]';
	scoreboard_t2.innerHTML = teams[1]?.name ?? '[???]';
	console.log(`HTML T1: ${scoreboard_t1.innerHTML}`);
	console.log(`HTML T2: ${scoreboard_t2.innerHTML}`);

	//file_exists("../" + teams[0]?.logo_uri).then((exists: boolean) => {
	//	if (exists) scoreboard_logo_1.src = "../" + teams[0]?.logo_uri
	//	else scoreboard_logo_1.src = "../assets/fallback.png"
	//})
	//file_exists("../" + teams[1]?.logo_uri).then((exists: boolean) => {
	//	if (exists) scoreboard_logo_2.src = "../" + teams[1]?.logo_uri
	//	else scoreboard_logo_2.src = "../assets/fallback.png"
	//})

	const scores: [number, number] = get_scores(game);
	console.log(`scores: ${scores}`);
	scoreboard_s1.innerHTML = md.meta.sides_inverted ? scores[1].toString() : scores[0].toString();
	scoreboard_s2.innerHTML = md.meta.sides_inverted ? scores[0].toString() : scores[1].toString();

	const default_col = "white";
	const left_col = teams[0]?.color ?? default_col;
	const right_col = teams[1]?.color ?? default_col;

	scoreboard_t1.style.background = gradient2str(str2col(left_col), str2coldark(left_col));
	scoreboard_t1.style.color = color_font_contrast(str2coldark(left_col));
	scoreboard_t2.style.background = gradient2str(str2coldark(right_col), str2col(right_col));
	scoreboard_t2.style.color = color_font_contrast(str2coldark(right_col));

	update_timer_html();
	update_scoreboard_timer();
}

function write_gameplan() {
	while (gameplan.children.length > 1) gameplan.removeChild(gameplan.lastChild!);

	const cur = md.meta.game_i; // TODO Index ab 0 so richtig?

	md.games.forEach((g: Game, i: number) => {
		const team_left = resolve_GameTeamSlot(g[1]);
		const team_right = resolve_GameTeamSlot(g[2]);
		const scores = get_scores(g);

		const default_col = "white";
		const left_col = team_left?.color ?? default_col;
		const right_col = team_right?.color ?? default_col;

		let line = document.createElement("div");
		line.classList.add("line");

		let t1 = document.createElement("div");
		t1.classList.add("bordered", "t1");
		t1.innerHTML = team_left?.name.toString() ?? "[???]";
		t1.style.background = gradient2str(str2col(left_col), str2coldark(left_col));
		t1.style.color = color_font_contrast(str2coldark(left_col));
		line.appendChild(t1);

		let s1 = document.createElement("div");
		s1.classList.add("bordered", "s1");
		s1.innerHTML = scores[0].toString();
		line.appendChild(s1);

		let s2 = document.createElement("div");
		s2.classList.add("bordered", "s2");
		s2.innerHTML = scores[1].toString();
		line.appendChild(s2);

		let t2 = document.createElement("div");
		t2.classList.add("bordered", "t2");
		t2.innerHTML = team_right?.name.toString() ?? "[???]";
		t2.style.background = gradient2str(str2coldark(right_col), str2col(right_col));
		t2.style.color = color_font_contrast(str2coldark(right_col));
		line.appendChild(t2);

		if (cur < i) {
			line.style.opacity = "0.9";
			s1.innerHTML = "?";
			s2.innerHTML = "?";
			t1.style.color = "#bebebe";
			t2.style.color = "#bebebe";
			s1.style.color = "#bebebe";
			s2.style.color = "#bebebe";
			s1.style.backgroundColor = "black";
			s2.style.backgroundColor = "black";
		}

		gameplan.appendChild(line);
	});

	// TODO
	function smooth_scroll_to(target_y: number, duration: number = 2_000) {
		const start_y = scroller.scrollTop;
		const delta_y = target_y - start_y;
		const start_time = performance.now();

		function step(cur_time: number) {
			const elapsed = cur_time - start_time;
			const progress = Math.min(elapsed / duration, 1);
			const eased = progress < 0.5
				? 2 * progress * progress // easeIn
				: -1 + (4 - 2 * progress) * progress; // easeOut

			scroller.scrollTop = start_y + delta_y * eased;

			if (progress < 1) requestAnimationFrame(step);
		}

		requestAnimationFrame(step);
	}

	if (md.games.length > 10) {
		gameplan.parentElement?.classList.add("masked");
		setTimeout(() => {
			smooth_scroll_to(scroller.scrollHeight, SCROLL_DURATION);

			setTimeout(() => {
				smooth_scroll_to(0, SCROLL_DURATION);
			}, SCROLL_DURATION + 2_000); // duration + delay
		}, 2_000);
	}
}

function write_gamestart() {
	gamestart_t1.innerHTML = "";
	gamestart_t2.innerHTML = "";

	const default_col = "white";

	const teams_cur = get_teams(md.games[md.meta.game_i] ?? null);
	const left_col_cur = teams_cur[0]?.color ?? default_col;
	const right_col_cur = teams_cur[1]?.color ?? default_col;

	const t1_keeper = teams_cur[0]?.players.find((p) => p.role === "keeper")?.name ?? "[???]";
	const t1_field = teams_cur[0]?.players.find((p) => p.role === "field")?.name ?? "[???]";
	const t2_keeper = teams_cur[1]?.players.find((p) => p.role === "keeper")?.name ?? "[???]";
	const t2_field = teams_cur[1]?.players.find((p) => p.role === "field")?.name ?? "[???]";

	const teams_next = get_teams(md.games[md.meta.game_i + 1] ?? null);
	const left_col_next = teams_next[0]?.color ?? default_col;
	const right_col_next = teams_next[1]?.color ?? default_col;

	const t1_el = document.createElement("div");
	t1_el.classList.add("team");

	const t1_name_el = document.createElement("div");
	t1_name_el.classList.add("bordered");
	t1_name_el.style.fontSize = "60px";
	t1_name_el.style.background = gradient2str(str2col(left_col_cur), str2coldark(left_col_cur));
	t1_name_el.style.color = color_font_contrast(str2coldark(left_col_cur));
	t1_name_el.innerHTML = teams_cur[0]?.name.toString() ?? "[???]";

	const t1_keeper_el = document.createElement("div");
	t1_keeper_el.classList.add("bordered", "player");
	t1_keeper_el.style.backgroundColor = "#bebebe";
	t1_keeper_el.innerHTML = t1_keeper;

	const t1_field_el = document.createElement("div");
	t1_field_el.classList.add("bordered", "player");
	t1_field_el.style.backgroundColor = "#bebebe";
	t1_field_el.innerHTML = t1_field;

	gamestart_t1.appendChild(t1_name_el);
	gamestart_t1.appendChild(t1_keeper_el);
	gamestart_t1.appendChild(t1_field_el);

	const t2_name_el = document.createElement("div");
	t2_name_el.classList.add("bordered");
	t2_name_el.style.fontSize = "60px";
	t2_name_el.style.background = gradient2str(str2col(right_col_cur), str2coldark(right_col_cur));
	t2_name_el.style.color = color_font_contrast(str2coldark(right_col_cur));
	t2_name_el.innerHTML = teams_cur[1]?.name.toString() ?? "[???]";

	const t2_keeper_el = document.createElement("div");
	t2_keeper_el.classList.add("bordered", "player");
	t2_keeper_el.style.backgroundColor = "#bebebe";
	t2_keeper_el.innerHTML = t2_keeper;

	const t2_field_el = document.createElement("div");
	t2_field_el.classList.add("bordered", "player");
	t2_field_el.style.backgroundColor = "#bebebe";
	t2_field_el.innerHTML = t2_field;

	gamestart_t2.appendChild(t2_name_el);
	gamestart_t2.appendChild(t2_keeper_el);
	gamestart_t2.appendChild(t2_field_el);

	if (teams_next[0] == null && teams_next[1] == null) gamestart_next.style.display = "none";
	else {
		gamestart_next.style.display = "block";
		gamestart_next_t1.innerHTML = teams_next[0]?.name.toString() ?? "[???]";
		gamestart_next_t1.style.background =
			gradient2str(str2col(left_col_next), str2coldark(left_col_next));
		gamestart_next_t2.innerHTML = teams_next[1]?.name.toString() ?? "[???]";
		gamestart_next_t2.style.background =
			gradient2str(str2col(right_col_next), str2coldark(right_col_next));
		gamestart_next_t1.style.color = color_font_contrast(str2col(gamestart_next_t1.style.backgroundColor));
		gamestart_next_t2.style.color = color_font_contrast(str2col(gamestart_next_t2.style.backgroundColor));
	}
}

// TODO refactor as handler function for displaying a GameAction
//function write_card(player_index: number, type: string) {
//	card_receiver.innerHTML = md.players[player_index].name.toString() //TODO do we need toString?
//	// TODO make the card system more flexible
//	switch (type) {
//		case "Y":
//			card_graphic.style.backgroundColor = "#ffff00"
//			card_message.innerHTML = "bekommt eine gelbe Karte"
//			break
//		case "R":
//			card_graphic.style.backgroundColor = "#ff0000"
//			card_message.innerHTML = "bekommt eine rote Karte"
//			break
//		default:
//			console.error("Unknown CardType... exiting")
//			return // TODO can we do that and no UI appears?
//	}
//
//	md.games[md.meta.game_i].cards[md.games[md.meta.game_i].cards.length] = {
//		player_index: player_index,
//		card_type: type
//	}
//
//	setTimeout(() => {
//		card.style.opacity = "0"
//		setTimeout(() => card.style.display = "none", 500)
//	}, CARD_SHOW_LENGTH)
//}

// TODO Does this need to be ?
type LivetableLine = {
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
};

// TODO make this function not suck
// (dont call everything 100 times, we do basically the same thing for every field)
function write_livetable() {
	while (livetable.children.length > 2) livetable.removeChild(livetable.lastChild!);

	let teams: LivetableLine[] = [];

	md.teams.forEach((t) => {
		console.log("Name: ", t.name);
		teams.push({
			name: t.name.toString(),
			points: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) { // TODO Count the game right now?
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t) {
						p += (get_scores(g)[0] - get_scores(g)[1] > 0) ? 3 : 0;
						p += (get_scores(g)[0] - get_scores(g)[1] === 0) ? 1 : 0;
					} else if (resolve_GameTeamSlot(g[2]) === t) {
						p += (get_scores(g)[0] - get_scores(g)[1] < 0) ? 3 : 0;
						p += (get_scores(g)[0] - get_scores(g)[1] === 0) ? 1 : 0;
					}
				}
				return p;
			})(),
			played: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t || resolve_GameTeamSlot(g[2]) === t) p++;
				}
				return p;
			})(),
			won: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] > 0) ? 1 : 0;
					else if (resolve_GameTeamSlot(g[2]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] < 0) ? 1 : 0;
				}
				return p;
			})(),
			tied: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] === 0) ? 1 : 0;
					else if (resolve_GameTeamSlot(g[2]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] === 0) ? 1 : 0;
				}
				return p;
			})(),
			lost: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] < 0) ? 1 : 0;
					else if (resolve_GameTeamSlot(g[2]) === t)
						p += (get_scores(g)[0] - get_scores(g)[1] > 0) ? 1 : 0;
				}
				return p;
			})(),
			goals: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t) p += get_scores(g)[0];
					else if (resolve_GameTeamSlot(g[2]) === t) p += get_scores(g)[1];
				}
				return p;
			})(),
			goals_taken: (() => {
				let p = 0;
				for (let j = 0; j < md.meta.game_i; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t) p += get_scores(g)[1];
					else if (resolve_GameTeamSlot(g[2]) === t) p += get_scores(g)[0];
				}
				return p;
			})(),
			color_right: str2col(t.color),
			color_left: str2coldark(t.color)
		});
	});

	teams.sort((a, b) => {
		if (b.points !== a.points) return b.points - a.points;
		if (b.goals - b.goals_taken !== a.goals - a.goals_taken)
			return (b.goals - b.goals_taken) - (a.goals - a.goals_taken);
		if (b.goals !== a.goals) return b.goals - a.goals;
		if (b.won !== a.won) return b.won - a.won;
		if (b.played !== a.played) return b.played - a.played;
		return a.name.localeCompare(b.name);
	});

	for (let team_i = 0; team_i < md.teams.length; team_i++) {
		const line = document.createElement("div");
		line.classList.add("line");

		const name = document.createElement("div");
		name.innerHTML = teams[team_i].name!.toString();
		name.classList.add("bordered", "name");
		name.style.background = gradient2str(teams[team_i].color_right, teams[team_i].color_left);
		name.style.color = color_font_contrast(teams[team_i].color_right!);
		line.appendChild(name);

		const points = document.createElement("div");
		points.innerHTML = teams[team_i].points!.toString();
		points.classList.add("bordered");
		line.appendChild(points);

		const played = document.createElement("div");
		played.innerHTML = teams[team_i].played!.toString();
		played.classList.add("bordered");
		line.appendChild(played);

		const won = document.createElement("div");
		won.innerHTML = teams[team_i].won!.toString();
		won.classList.add("bordered");
		line.appendChild(won);

		const tied = document.createElement("div");
		tied.innerHTML = teams[team_i].tied!.toString();
		tied.classList.add("bordered");
		line.appendChild(tied);

		const lost = document.createElement("div");
		lost.innerHTML = teams[team_i].lost!.toString();
		lost.classList.add("bordered");
		line.appendChild(lost);

		const goals = document.createElement("div");
		goals.innerHTML = `${teams[team_i].goals!.toString()}:${teams[team_i].goals_taken!.toString()}`;
		goals.classList.add("bordered");
		line.appendChild(goals);

		const diff = document.createElement("div");
		diff.innerHTML = (teams[team_i].goals! - teams[team_i].goals_taken!).toString();
		diff.classList.add("bordered");
		line.appendChild(diff);

		livetable.appendChild(line);
	}
}

let countdown = 0; // TODO ASK what is this?

// Will this work sub second when it only runs each second? We dont set timer each time we pause/unpause
function async_handle_time() {
	clearInterval(countdown);
	update_timer_html();
	countdown = setInterval(() => {
		update_scoreboard_timer();

		if (md.meta.paused) return;
		if (md.meta.cur_time <= 1) clearInterval(countdown);

		console.log("tick one down now: ", md.meta.cur_time);
		md.meta.cur_time--;

		update_timer_html();
	}, TIME_UPDATE_INTERVAL_MS);
}

function update_scoreboard_timer() {
	if (md.meta.cur_time === -1) return;
	const gp = cur_gamepart();
	if (gp?.type != "timed") return;
	const bar_width = Math.min(100, Math.max(0, (md.meta.cur_time / gp.length) * 100));
	scoreboard_time_bar.style.width = bar_width + "%";
}

function update_timer_html() {
	const minutes = Math.floor(md.meta.cur_time / 60).toString().padStart(2, "0");
	const seconds = (md.meta.cur_time % 60).toString().padStart(2, "0");
	console.log("update timer: min: " +  minutes +  "sec: " + seconds);
	scoreboard_time_minutes.innerHTML = minutes;
	scoreboard_time_seconds.innerHTML = seconds;
}

function update_ui() {
	console.log("updating ui")
	if (shown.scoreboard) write_scoreboard();
	if (shown.gameplan) write_gameplan();
	if (shown.livetable) write_livetable();
	if (shown.gamestart) write_gamestart();
	if (shown.ad) return; // write_ad() //TODO This does not exist, right?
}

function connect() {
	socket = new WebSocket("ws://mminl.de:8081", "interscore");
	socket.binaryType = "arraybuffer";

	socket.onopen = () => {
		function to_string(v: any) {
			if (typeof v === "string") return v;
			if (v instanceof Error) return v.stack || v.message;
			try {
				return JSON.stringify(v);
			} catch {
				return String(v);
			}
		}
		// TODO NOW wtf is origLog?
		const origLog = console.log;
		const origErr = console.error;
		console.log = (...args) => {
			socket.send(args.map(to_string).join(" "));
			origLog(...args); // optional
		};

		console.error = (...args) => {
			socket.send("[ERROR] " + args.map(to_string).join(" "));
			origErr(...args); // optional
		};

		console.log("Connected to WebSocket server!");
		socket.send(Uint8Array.of(MessageType.PLS_SEND_JSON).buffer);
	}

	socket.onmessage = (event: MessageEvent) => {
		console.log(`Received: stuff`);
		console.log(`Received: ${event.data}`);
		if (!(event.data instanceof ArrayBuffer)) {
			console.error("The backend didn't send proper binary data. There's nothing we can do...");
			return;
		}

		const dv = new DataView(event.data as ArrayBuffer);
		const mode = dv.getUint8(0);
		console.log(`mode: ${mode}, ${MessageType.DATA_WIDGET_SCOREBOARD_ON}`);

		switch (mode) {
			case MessageType.DATA_WIDGET_SCOREBOARD_ON: {
				console.log(`show: ${shown.scoreboard}`);
				scoreboard.style.opacity = "0"; // TODO READ why is this line present on both show and hide
				if (shown.scoreboard = dv.getUint8(1) == 1) {
					scoreboard.style.display = "inline-flex";
					setTimeout(() => scoreboard.style.opacity = "1", TIMEOUT_SHOW);
					console.log(`writing scoreboard!`);
				} else
					setTimeout(() => scoreboard.style.display = "none", TIMEOUT_HIDE);
				// TODO FINAL CONSIDER REPLACE write_scoreboard() etc...
				update_ui();
				break;
			}
			case MessageType.DATA_WIDGET_GAMEPLAN_ON: {
				gameplan.style.opacity = "0";
				if (shown.gameplan = dv.getUint8(1) == 1) {
					gameplan.style.display = "inline-flex";
					setTimeout(() => gameplan.style.opacity = "1", TIMEOUT_SHOW);
				} else
					setTimeout(() => gameplan.style.display = "none", TIMEOUT_HIDE);
				update_ui();
				break;
			}
			case MessageType.DATA_WIDGET_LIVETABLE_ON: {
				livetable.style.opacity = "0";
				if (shown.livetable = dv.getUint8(1) == 1) {
					livetable.style.display = "inline-flex";
					setTimeout(() => livetable.style.opacity = "1", TIMEOUT_SHOW);
				} else
					setTimeout(() => livetable.style.display = "none", TIMEOUT_HIDE);
				update_ui();
				break;
			}
			case MessageType.DATA_WIDGET_GAMESTART_ON: {
				gamestart.style.opacity = "0";
				if (shown.gamestart = dv.getUint8(1) == 1) {
					gamestart.style.display = "flex";
					setTimeout(() => gamestart.style.opacity = "1", TIMEOUT_SHOW);
				} else
					setTimeout(() => gamestart.style.display = "none", TIMEOUT_HIDE);
				update_ui();
				break;
			}
			case MessageType.DATA_WIDGET_AD_ON: { // TODO does this work?
				if (shown.ad = dv.getUint8(1) == 1) {
					ad.style.opacity = "0";
					ad.style.display = "block";
					setTimeout(() => ad.style.opacity = "1", TIMEOUT_SHOW);
				} else
					setTimeout(() => ad.style.display = "none", TIMEOUT_HIDE);
				update_ui();
				break;
			}
			//case MessageType.DATA_GAME_ACTION: {
			//	const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset, dv.byteLength))
			//	console.log(str);
			//	cur_game()?.actions.push(GameActionSchema.parse(str)); // TODO what if this fails somehow?
			//	update_ui()
			//	break
			//}
			case MessageType.DATA_GAMEINDEX:
				// ^ TODO CONSIDER RENAME
				console.log("Received DATA Gameindex: ", dv.getUint8(1));
				md.meta.game_i = dv.getUint8(1);
				update_ui();
				break;
			case MessageType.DATA_PAUSE_ON:
				console.log("Received DATA is_pause: ", dv.getUint8(1) === 1);
				md.meta.paused = dv.getUint8(1) === 1;
				break;
			case MessageType.DATA_TIME:
				console.log("Received DATA time: ", dv.getUint16(1, false));
				md.meta.cur_time = dv.getUint16(1, false);
				update_ui();
				break;
			case MessageType.DATA_SIDES_SWITCHED:
				md.meta.sides_inverted = dv.getUint8(1) == 1;
				update_ui();
				break;
			case MessageType.DATA_JSON:
				// ^ TODO CONSIDER RENAME
				console.log("Received DATA JSON");
				const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset, dv.byteLength));
				md = json_parse(str);
				update_ui();
				break;
			//case MessageType.SCOREBOARD_SET_TIMER:
			// TODO This is actually useful, implement in rentnerend
			// TODO make this work
			//scoreboard_set_timer(parseInt(buffer.charCodeAt(1) + buffer.charCodeAt(2)))
			//	break
		}
	}

	socket.onerror = (error: Event) => console.error("WebSocket Error: ", error);
	socket.onclose = () => {
		console.warn("WebSocket connection closed! Reconnecting in 3s");
		reconnect_timer = window.setTimeout(connect, 3_000);
	}
}

connect();
async_handle_time();
console.log("Client loaded!");

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
