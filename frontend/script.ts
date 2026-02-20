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
const GamePartPausedTimedSchema = z.object({
	type: z.literal("pause_timed"),
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
	GamePartPausedTimedSchema,
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
	id: z.number(),
	change: z.object({
		// type: z.literal("score"),
		score: z.object({
			'1': z.number().default(0),
			'2': z.number().default(0),
		}),
	}),
	triggers_action: z.number().nullable().default(null),
});

const GameActionFoulSchema = GameActionBaseSchema.extend({
	type: z.literal("foul"),
	id: z.number(),
	triggers_action: z.number().nullable().default(null),
});

const GameActionPenaltySchema = GameActionBaseSchema.extend({
	type: z.literal("penalty"),
	id: z.number(),
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

const MetaGameSchema = z.object({
	index: z.number().default(0),
	gamepart: z.number().default(0),
	sides_inverted: z.boolean().default(false),
	ended: z.boolean().default(false)
});

const MetaTimeSchema = z.object({
	remaining: z.number().default(0),
	last_unpaused: z.number().default(0),
	paused: z.boolean().default(true),
	delay: z.number().default(0) // TODO make delay work correctly
})

const MetaWidgetsSchema = z.object({
	scoreboard: z.boolean().default(false),
	gameplan: z.boolean().default(false),
	liveplan: z.boolean().default(false),
	gamestart: z.boolean().default(false),
	ad: z.boolean().default(false),
})

const MetaObsSchema = z.object({
	streamStarted: z.boolean().default(false),
	replayStarted: z.boolean().default(false)
})

const MetaSchema = z.object({
	game: MetaGameSchema,
	time: MetaTimeSchema,
	widgets: MetaWidgetsSchema,
	obs: MetaObsSchema
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
	formats: z.array(FormatSchema),
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
		game: {
			index: 0,
			gamepart: 0,
			sides_inverted: false,
			ended: false
		},
		time: {
			remaining: 0,
			last_unpaused: 0,
			paused: true,
			delay: 0
		},
		widgets: {
			scoreboard: false,
			gameplan: false,
			liveplan: false,
			gamestart: false,
			ad: false
		},
		obs: {
			streamStarted: false,
			replayStarted: false
		}
	},
	formats: [],
	games: [],
	groups: [],
	teams: []
};

// Time delay relative to the Interscore Controller
let delay = 0;

function cur_game(): (Game | null) {
	return md.games[md.meta.game.index];
}

function cur_format(): (Format | null) {
	return (md.formats.find((f) => f.name === cur_game()?.format.name)) ?? null;
}

function cur_gamepart(): (GamePart | null) {
	return cur_format()?.gameparts[md.meta.game.gamepart] ?? null;
}

function running_time(md: Matchday): number {
	if (md.meta.time.paused) return md.meta.time.remaining;
	const now = Math.floor(Date.now() / 1_000);
	return md.meta.time.remaining - (now + delay - md.meta.time.last_unpaused);
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
	return md.meta.game.sides_inverted ? [team_right, team_left] : [team_left, team_right];
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
	const game = md.games[md.meta.game.index];

	const teams = get_teams(game);

	scoreboard_t1.innerHTML = teams[0]?.name ?? '[???]';
	scoreboard_t2.innerHTML = teams[1]?.name ?? '[???]';

	//file_exists("../" + teams[0]?.logo_uri).then((exists: boolean) => {
	//	if (exists) scoreboard_logo_1.src = "../" + teams[0]?.logo_uri
	//	else scoreboard_logo_1.src = "../assets/fallback.png"
	//})
	//file_exists("../" + teams[1]?.logo_uri).then((exists: boolean) => {
	//	if (exists) scoreboard_logo_2.src = "../" + teams[1]?.logo_uri
	//	else scoreboard_logo_2.src = "../assets/fallback.png"
	//})

	const scores: [number, number] = get_scores(game);
	scoreboard_s1.innerHTML = md.meta.game.sides_inverted ? scores[1].toString() : scores[0].toString();
	scoreboard_s2.innerHTML = md.meta.game.sides_inverted ? scores[0].toString() : scores[1].toString();

	const default_col = "white";
	const left_col = teams[0]?.color ?? default_col;
	const right_col = teams[1]?.color ?? default_col;

	scoreboard_t1.style.background = gradient2str(str2col(left_col), str2coldark(left_col));
	scoreboard_t1.style.color = color_font_contrast(str2coldark(left_col));
	scoreboard_t2.style.background = gradient2str(str2coldark(right_col), str2col(right_col));
	scoreboard_t2.style.color = color_font_contrast(str2coldark(right_col));

	const rt = running_time(md);
	update_timer_html(rt);
	update_scoreboard_timer(rt);
}

function write_gameplan() {
	while (gameplan.children.length > 1) gameplan.removeChild(gameplan.lastChild!);

	const cur = md.meta.game.index; // TODO Index ab 0 so richtig?

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

	console.log(md.games);
	console.log(md.meta);
	const teams_cur = get_teams(md.games[md.meta.game.index]);
	console.log(teams_cur);
	const left_col_cur = teams_cur[0]?.color ?? default_col;
	const right_col_cur = teams_cur[1]?.color ?? default_col;

	const t1_keeper = teams_cur[0]?.players.find(p => p.role === "keeper")?.name ?? "[???]";
	const t1_field = teams_cur[0]?.players.find(p => p.role === "field")?.name ?? "[???]";
	const t2_keeper = teams_cur[1]?.players.find(p => p.role === "keeper")?.name ?? "[???]";
	const t2_field = teams_cur[1]?.players.find(p => p.role === "field")?.name ?? "[???]";

	const teams_next = md.meta.game.index+1 < md.games.length ? get_teams(md.games[md.meta.game.index + 1]) : null;
	const left_col_next = teams_next?.[0]?.color ?? default_col;
	const right_col_next = teams_next?.[1]?.color ?? default_col;

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

	if (teams_next?.[0] == null && teams_next?.[1] == null) gamestart_next.style.display = "none";
	else {
		gamestart_next.style.display = "block";
		gamestart_next_t1.innerHTML = teams_next[0]?.name.toString() ?? "[???]";
		gamestart_next_t1.style.background =
			gradient2str(str2col(left_col_next), str2coldark(left_col_next));
		gamestart_next_t2.innerHTML = teams_next[1]?.name.toString() ?? "[???]";
		gamestart_next_t2.style.background =
			gradient2str(str2coldark(right_col_next), str2col(right_col_next));
		gamestart_next_t1.style.color = color_font_contrast(str2col(left_col_next));
		gamestart_next_t2.style.color = color_font_contrast(str2col(right_col_next));
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
//	md.games[md.meta.game.index].cards[md.games[md.meta.game_i].cards.length] = {
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
	let last_index = md.meta.game.ended ? md.games.length : md.meta.game.index;

	md.teams.forEach((t) => {
		teams.push({
			name: t.name.toString(),
			points: (() => {
				let p = 0;
				for (let j = 0; j < last_index; j++) {
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
				for (let j = 0; j < last_index; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t || resolve_GameTeamSlot(g[2]) === t) p++;
				}
				return p;
			})(),
			won: (() => {
				let p = 0;
				for (let j = 0; j < last_index; j++) {
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
				for (let j = 0; j < last_index; j++) {
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
				for (let j = 0; j < last_index; j++) {
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
				for (let j = 0; j < last_index; j++) {
					const g: Game = md.games[j];
					if (resolve_GameTeamSlot(g[1]) === t) p += get_scores(g)[0];
					else if (resolve_GameTeamSlot(g[2]) === t) p += get_scores(g)[1];
				}
				return p;
			})(),
			goals_taken: (() => {
				let p = 0;
				for (let j = 0; j < last_index; j++) {
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

let countdown = 0;

// TODO Will this work sub second when it only runs each second? We dont set timer each time we pause/unpause
function async_handle_time() {
	clearInterval(countdown);
	update_timer_html(running_time(md));
	countdown = setInterval(() => {
		const rt = running_time(md);
		update_scoreboard_timer(rt);

		if (md.meta.time.paused) return;

		update_timer_html(rt);
	}, TIME_UPDATE_INTERVAL_MS);
}

function update_scoreboard_timer(rt: number) {
	if (md.meta.time.remaining <= 0 || rt <= 0) return;

	const gp = cur_gamepart();
	if (gp?.type != "timed" && gp?.type != "pause_timed") return;

	const bar_width = Math.min(100, Math.max(0, (rt / gp.length) * 100));
	scoreboard_time_bar.style.width = bar_width + "%";
}

function update_timer_html(rt: number) {
	const minutes = Math.floor(rt / 60).toString().padStart(2, "0");
	const seconds = (rt % 60).toString().padStart(2, "0");
	scoreboard_time_minutes.innerHTML = minutes;
	scoreboard_time_seconds.innerHTML = seconds;
}

function update_ui() {
	if (md.meta.widgets.scoreboard) write_scoreboard();
	if (md.meta.widgets.gameplan) write_gameplan();
	if (md.meta.widgets.liveplan) write_livetable();
	if (md.meta.widgets.gamestart) write_gamestart();
	if (md.meta.widgets.ad) return; // write_ad() //TODO This does not exist, right?
}

function connect() {
	socket = new WebSocket("ws://localhost:8081", "interscore");
	socket.binaryType = "arraybuffer";

	socket.onopen = () => {
		console.log("Connected to WebSocket server!");
		socket.send(Uint8Array.of(MessageType.PLS_SEND_JSON).buffer);
	}

	socket.onmessage = (event: MessageEvent) => {
		if (!(event.data instanceof ArrayBuffer)) {
			console.error("The backend didn't send proper binary data. There's nothing we can do...");
			return;
		}

		const dv = new DataView(event.data as ArrayBuffer);
		const mode = dv.getUint8(0);

		switch (mode) {
			case MessageType.DATA_META: {
				console.log("Received DATA_META");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				md.meta = MetaSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_META_GAME: {
				console.log("Received DATA_META_GAME");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				md.meta.game = MetaGameSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_META_TIME: {
				console.log("Received DATA_META_TIME");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				md.meta.time = MetaTimeSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_META_OBS: {
				console.log("Received DATA_META_OBS");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				md.meta.obs = MetaObsSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_META_WIDGETS: {
				console.log("Received DATA_META_WIDGETS");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));

				const new_meta_widgets = MetaWidgetsSchema.parse(JSON.parse(str))
				if(new_meta_widgets.scoreboard != md.meta.widgets.scoreboard) {
					// TODO READ why is this line present on both show and hide
					scoreboard.style.opacity = "0";
					if (new_meta_widgets.scoreboard) {
						scoreboard.style.display = "inline-flex";
						setTimeout(() => scoreboard.style.opacity = "1", TIMEOUT_SHOW);
					} else
						setTimeout(() => scoreboard.style.display = "none", TIMEOUT_HIDE);
				}
				if(new_meta_widgets.gameplan != md.meta.widgets.gameplan) {
					// TODO READ why is this line present on both show and hide
					gameplan.style.opacity = "0";
					if (new_meta_widgets.gameplan) {
						gameplan.style.display = "inline-flex";
						setTimeout(() => gameplan.style.opacity = "1", TIMEOUT_SHOW);
					} else
						setTimeout(() => gameplan.style.display = "none", TIMEOUT_HIDE);
				}
				if(new_meta_widgets.liveplan != md.meta.widgets.liveplan) {
					// TODO READ why is this line present on both show and hide
					livetable.style.opacity = "0";
					if (new_meta_widgets.liveplan) {
						livetable.style.display = "inline-flex";
						setTimeout(() => livetable.style.opacity = "1", TIMEOUT_SHOW);
					} else
						setTimeout(() => livetable.style.display = "none", TIMEOUT_HIDE);
				}
				if(new_meta_widgets.gamestart != md.meta.widgets.gamestart) {
					// TODO READ why is this line present on both show and hide
					gamestart.style.opacity = "0";
					if (new_meta_widgets.gamestart) {
						gamestart.style.display = "inline-flex";
						setTimeout(() => gamestart.style.opacity = "1", TIMEOUT_SHOW);
					} else
						setTimeout(() => gamestart.style.display = "none", TIMEOUT_HIDE);
				}
				if(new_meta_widgets.ad != md.meta.widgets.ad) {
					// TODO READ why is this line present on both show and hide
					ad.style.opacity = "0";
					if (new_meta_widgets.ad) {
						ad.style.display = "inline-flex";
						setTimeout(() => ad.style.opacity = "1", TIMEOUT_SHOW);
					} else
						setTimeout(() => ad.style.display = "none", TIMEOUT_HIDE);
				}
				md.meta.widgets = new_meta_widgets; // TODO is this a shallow copy?
				update_ui();
				break;
			}
			case MessageType.DATA_GAMES: {
				console.log("Received DATA_GAMES");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				const GamesSchema = z.array(GameSchema);
				md.games = GamesSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_GAME: {
				console.log("Received DATA_GAME");
				if(dv.byteLength < 2) {
					console.log("DATA_GAME's length is only 1... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.games.length) {
					console.log(`DATA_GAME's index is out of bound: ${0}-${md.games.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, 2, dv.byteLength-2));
				md.games[index] = GameSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_GAMEACTIONS: {
				console.log("Received DATA_GAMEACTIONS");
				if(dv.byteLength < 3) {
					console.log("DATA_GAMEACTIONS's length is less than 3... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.games.length) {
					console.log(`DATA_GAME's index is out of bound: ${0}-${md.games.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset + 2, dv.byteLength-2));
				const GameActionsSchema = z.array(GameActionSchema);
				md.games[index].actions = GameActionsSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_GAMEACTION: {
				console.log("Received DATA_GAMEACTION");
				if(dv.byteLength < 3) {
					console.log("DATA_GAMEACTION's length is less than 3... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.games.length) {
					console.log(`DATA_GAMEACTION's index is out of bound: ${0}-${md.games.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset + 2, dv.byteLength-2));
				const action = GameActionSchema.parse(JSON.parse(str));

				const action_index = md.games[index].actions.findIndex((a) => a.id == action.id);
				if(action_index != -1)
					md.games[index].actions[action_index] = action;
				else
					md.games[index].actions.push(action);
				update_ui();
				break;
			}
			case MessageType.DATA_FORMATS: {
				console.log("Received DATA_FORMATS");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				const FormatsSchema = z.array(FormatSchema);
				md.formats = FormatsSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_FORMAT: {
				console.log("Received DATA_FORMAT");
				if(dv.byteLength < 3) {
					console.log("DATA_FORMAT's length is less than 3... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.formats.length) {
					console.log(`DATA_FORMAT's index is out of bound: ${0}-${md.formats.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, 2, dv.byteLength-2));
				md.formats[index] = FormatSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_TEAMS: {
				console.log("Received DATA_TEAMS");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				const TeamsSchema = z.array(TeamSchema);
				md.teams = TeamsSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_TEAM: {
				console.log("Received DATA_TEAM");
				if(dv.byteLength < 3) {
					console.log("DATA_TEAM's length is less than 3... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.teams.length) {
					console.log(`DATA_TEAM's index is out of bound: ${0}-${md.teams.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, 2, dv.byteLength-2));
				md.teams[index] = TeamSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_GROUPS: {
				console.log("Received DATA_GROUPS");
				const str = decoder.decode(new Uint8Array(dv.buffer, 1, dv.byteLength-1));
				const GroupsSchema = z.array(GroupSchema);
				md.groups = GroupsSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_GROUP: {
				console.log("Received DATA_GROUP");
				if(dv.byteLength < 3) {
					console.log("DATA_GROUP's length is less than 3... Ragebait... ignoring");
					break;
				}
				const index = dv.getUint8(1);
				if(index < 0 || index > md.groups.length) {
					console.log(`DATA_GROUP's index is out of bound: ${0}-${md.teams.length} but is: ${index}`);
					break;
				}
				const str = decoder.decode(new Uint8Array(dv.buffer, 2, dv.byteLength-2));
				md.groups[index] = GroupSchema.parse(JSON.parse(str));
				update_ui();
				break;
			}
			case MessageType.DATA_IM_BOSS:
				console.log("WARN: We received DATA_IM_BOSS, but we should never receive this! Ignoring...");
				break;
			case MessageType.DATA_JSON: {
				console.log("Received DATA JSON");
				const str = decoder.decode(new Uint8Array(dv.buffer, dv.byteOffset + 1, dv.byteLength-1));
				md = json_parse(str);
				update_ui();
				break;
			}
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
