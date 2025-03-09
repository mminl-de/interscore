#include <pthread.h>
#include <stdbool.h>
#include <time.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
#include "mongoose/mongoose.h"

#include "config.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

// Each WIDGET_* elements except WIDGET_CARD_SHOW means disable,
// the successor means enable/update.
// This widget is mirrored in frontend/script.ts.
enum WidgetMessage {
	WIDGET_SCOREBOARD = 1,
	WIDGET_LIVETABLE = 3,
	WIDGET_GAMEPLAN = 5,
	WIDGET_GAMESTART = 7,
	WIDGET_CARD_SHOW = 9,
	SCOREBOARD_SET_TIMER = 10,
	SCOREBOARD_PAUSE_TIMER = 11
};
enum CardType { YELLOW, RED };
enum PlayerRole { KEEPER, FIELD };
enum InputType {
	T1_SCORE_PLUS, T1_SCORE_MINUS, T2_SCORE_PLUS, T2_SCORE_MINUS,
	GAME_NEXT, GAME_PREV, GAME_SWITCH_SIDES,
	TIME_PLUS, TIME_MINUS, TIME_TOGGLE_PAUSE, TIME_RESET
};

#pragma pack(push, 1)
typedef struct { u8 r, g, b; } Color;

typedef struct {
	u8 widget_num;
	char team1[TEAMS_NAME_MAX_LEN];
	char team2[TEAMS_NAME_MAX_LEN];
	u8 score_t1;
	u8 score_t2;
	bool is_halftime;
	Color team1_color_left;
	Color team1_color_right;
	Color team2_color_left;
	Color team2_color_right;
} WidgetScoreboard;

typedef struct {
	u8 widget_num;
	char team1_keeper[TEAMS_NAME_MAX_LEN];
	char team1_field[TEAMS_NAME_MAX_LEN];
	char team2_keeper[TEAMS_NAME_MAX_LEN];
	char team2_field[TEAMS_NAME_MAX_LEN];
	Color team1_color_left;
	Color team1_color_right;
	Color team2_color_left;
	Color team2_color_right;
} WidgetGamestart;

typedef struct {
	u8 widget_num;
	u8 len; // amount of teams total
	char teams[TEAMS_COUNT_MAX][TEAMS_NAME_MAX_LEN]; // sorted
	u8 points[TEAMS_COUNT_MAX];
	u8 games_played[TEAMS_COUNT_MAX];
	u8 games_won[TEAMS_COUNT_MAX];
	u8 games_tied[TEAMS_COUNT_MAX];
	u8 games_lost[TEAMS_COUNT_MAX];
	u16 goals[TEAMS_COUNT_MAX];
	u16 goals_taken[TEAMS_COUNT_MAX];
	Color color[TEAMS_COUNT_MAX];
} WidgetLivetable;

typedef struct {
	u8 widget_num;
	u8 len; // amount of Games total
	char teams1[GAMES_COUNT_MAX][TEAMS_NAME_MAX_LEN];
	char teams2[GAMES_COUNT_MAX][TEAMS_NAME_MAX_LEN];
	u8 goals_t1[GAMES_COUNT_MAX];
	u8 goals_t2[GAMES_COUNT_MAX];
	Color team1_color_left[GAMES_COUNT_MAX];
	Color team1_color_right[GAMES_COUNT_MAX];
	Color team2_color_left[GAMES_COUNT_MAX];
	Color team2_color_right[GAMES_COUNT_MAX];
} WidgetGameplan;

typedef struct {
	u8 widget_num;
	enum CardType type;
	char name[PLAYER_NAME_MAX_LEN];
} WidgetCard;
#pragma pack(pop)

// #### In Game Structs

typedef struct {
	u8 t1;
	u8 t2;
} Score;

typedef struct {
	u8 player_index;
	enum CardType card_type;
} Card;

typedef struct {
	char *name;
	u8 team_index;
	enum PlayerRole role;
} Player;

typedef struct {
	u8 keeper_index;
	u8 field_index;
	char *name;
	char *logo_filename;
	char *color_light;
	char *color_dark;
} Team;

typedef struct {
	u8 t1_index;
	u8 t2_index;
	Score halftimescore;
	Score score;
	Card *cards;
	u8 cards_count;
} Game;

typedef struct {
	struct {
		u8 gameindex; // index of the current game played in the games array
		bool halftime; // 0: first half, 1: second half
		bool pause;
		u16 time;
	} cur;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
} Matchday;

/*
Possible User Actions:
####### Ingame Stuff
- Set Time (DONE)
- Add Time (DONE)
- go a game forward (DONE)
- go a game back (DONE)
- goal Team 1 (DONE)
- goal Team 2 (DONE)
- Yellow Card to Player 1, 2, 3 or 4 (DONE)
- Red Card to Player 1, 2, 3 or 4 (DONE)
- Switch Team Sides (without halftime)
- Half Time
## Error Handling
- minus goal team 1 (DONE)
- minus goal team 2 (DONE)
- delete card (DONE)
####### UI Stuff
- Enable/Disable ==> Scoreboard Widget
- Start ==> Start of the game/halftime animation
- Enable/Disable ==> Halftime Widget
- enable/Disable ==> Live Table Widget
- Enable/Disable ==> Tunierverlauf Widget
####### Debug Stuff
- Exit (DONE)
- Write State to JSON?
- Reload JSON
- Print State to Terminal?
- Print Connection State to Terminal?
- Print all possible commands
- Print current Gamestate
*/

// Define the input characters:
// Changing game time
//#define ADD_SECOND '+'
//#define REMOVE_SECOND '-'
#define PAUSE_TIME '='
#define SET_TIME 't'

// Switching games
#define GAME_FORWARD 'n'
#define GAME_BACK 'p'
#define GAME_HALFTIME 'h'

// Goals
#define GOAL_TEAM_1 '1'
#define GOAL_TEAM_2 '2'
#define REMOVE_GOAL_TEAM_1 '3'
#define REMOVE_GOAL_TEAM_2 '4'

// Justice system
#define DEAL_YELLOW_CARD 'y'
#define DEAL_RED_CARD 'r'
#define DELETE_CARD 'd'

// Widget toggling
#define TOGGLE_WIDGET_SCOREBOARD 'i'
#define TOGGLE_WIDGET_LIVETABLE 'l'
#define TOGGLE_WIDGET_GAMEPLAN 'v'
#define TOGGLE_WIDGET_GAMESTART 's'

// Meta
#define EXIT 'q'
#define RELOAD_JSON 'j'
#define PRINT_HELP '?'

// Other
#define TEST '6'

//TODO put all function definitions here
u16 team_calc_points(u8 index);
u8 team_calc_games_played(u8 index);
u8 team_calc_games_won(u8 index);
u8 team_calc_games_tied(u8 index);
u16 team_calc_goals(u8 index);
u16 team_calc_goals_taken(u8 index);

bool running = true;
Matchday md;
// We pretty much have to do this in gloabl scope bc at least ev_handler (TODO FINAL DECIDE is this possible/better with smaller scope)
struct mg_connection *client_con = NULL;
struct mg_mgr mgr;

bool WidgetScoreboard_enabled = false;
bool WidgetGamestart_enabled = false;
bool WidgetLivetable_enabled = false;
bool WidgetGameplan_enabled = false;

// TODO send_WidgetCard(WidgetCard w) {
//
// }

// Converts '0'-'9', 'a'-'f', 'A'-'F' to 0-15.
u8 hex_char_to_int(char c) {
    return (c & 0xF) + (c >> 6) * 9;
}

// Converts color as hexcode to rgb.
Color Color_from_hex(const char *hex) {
    return (Color) {
        (hex_char_to_int(hex[0]) << 4) | hex_char_to_int(hex[1]),
        (hex_char_to_int(hex[2]) << 4) | hex_char_to_int(hex[3]),
        (hex_char_to_int(hex[4]) << 4) | hex_char_to_int(hex[5])
    };
}

int qsort_helper_u8(const void *p1, const void *p2) {
	if(*(int*)p1 < *(int*)p2)
		return -1;
	if(*(int*)p1 > *(int*)p2)
		return 1;
	return 0;
}

// To send a widget with this function, convert it to a string with a cast.
bool send_widget(void *w) {
	if (client_con == NULL) {
		fprintf(stderr, "ERROR: Client not connected, couldn't send widget!\n");
		return false;
	}
	mg_ws_send(client_con, (char *) w, sizeof(WidgetScoreboard), WEBSOCKET_OP_BINARY);
	return true;
}

WidgetScoreboard WidgetScoreboard_create() {
	WidgetScoreboard w;
	w.widget_num = WIDGET_SCOREBOARD + WidgetScoreboard_enabled;

	if (md.cur.halftime) {
		strcpy(w.team2, md.teams[md.games[md.cur.gameindex].t1_index].name);
		strcpy(w.team1, md.teams[md.games[md.cur.gameindex].t2_index].name);
		w.score_t2 = md.games[md.cur.gameindex].score.t1;
		w.score_t1 = md.games[md.cur.gameindex].score.t2;

		w.team1_color_left = Color_from_hex(md.teams[md.games[md.cur.gameindex].t2_index].color_light);
		w.team1_color_right = Color_from_hex(md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
		w.team2_color_left = Color_from_hex(md.teams[md.games[md.cur.gameindex].t1_index].color_dark);
		w.team2_color_right = Color_from_hex(md.teams[md.games[md.cur.gameindex].t1_index].color_light);
	} else {
		strcpy(w.team1, md.teams[md.games[md.cur.gameindex].t1_index].name);
		strcpy(w.team2, md.teams[md.games[md.cur.gameindex].t2_index].name);
		w.score_t1 = md.games[md.cur.gameindex].score.t1;
		w.score_t2 = md.games[md.cur.gameindex].score.t2;

		w.team1_color_left = Color_from_hex(md.teams[md.games[md.cur.gameindex].t1_index].color_light);
		w.team1_color_right = Color_from_hex(md.teams[md.games[md.cur.gameindex].t1_index].color_dark);
		w.team2_color_left = Color_from_hex(md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
		w.team2_color_right = Color_from_hex(md.teams[md.games[md.cur.gameindex].t2_index].color_light);
	}

	w.is_halftime = md.cur.halftime;
	return w;
}

WidgetGamestart WidgetGamestart_create() {
	// TODO ADD colors
	WidgetGamestart w;
	w.widget_num = WIDGET_GAMESTART + WidgetGamestart_enabled;
	strcpy(w.team1_keeper, md.players[md.teams[md.games[md.cur.gameindex].t1_index].keeper_index].name);
	strcpy(w.team1_field, md.players[md.teams[md.games[md.cur.gameindex].t1_index].field_index].name);
	strcpy(w.team2_keeper, md.players[md.teams[md.games[md.cur.gameindex].t2_index].keeper_index].name);
	strcpy(w.team2_field, md.players[md.teams[md.games[md.cur.gameindex].t2_index].field_index].name);
	return w;
}

WidgetLivetable WidgetLivetable_create() {
	printf("begin livetable\n");
	WidgetLivetable w;
	w.widget_num = WIDGET_LIVETABLE + WidgetLivetable_enabled;
	w.len = md.teams_count;
	int teams_done[md.teams_count];
	int points[md.teams_count], goalratio[md.teams_count], goals[md.teams_count];
	for (u8 i = 0; i < md.teams_count; i++) {
		//punkte
		points[i] = team_calc_points(i);
		//torverhältnis
		goalratio[i] = team_calc_goals(i) - team_calc_goals_taken(i);
		//Mehr Tore
		goals[i] = team_calc_goals(i);
	}
	qsort(points, md.teams_count, sizeof(u8), qsort_helper_u8);
	qsort(goalratio, md.teams_count, sizeof(u8), qsort_helper_u8);
	qsort(goals, md.teams_count, sizeof(u8), qsort_helper_u8);
	for (u8 i = 0; i < md.teams_count; i++) {
		u8 j;
		for(j=i; j < md.teams_count-1 && points[j] != points[j+1]; j++);
		if(j<i); // wtf
		//TODO STARTHERE
	}
	for (u8 i = 0; i < md.teams_count; i++) {
		//init best_index with first, not yet done team
		u8 best_index = 0;
		for(int k=0; k < i; k++){
			if(k != teams_done[k]){
				best_index = k;
				break;
			}
		}
		printf("INDEX DEF: %d\n", best_index);
		//search for better team without entry
		for(int j=0; j < md.teams_count; j++){
			int skip = false;
			if(team_calc_points(best_index) < team_calc_points(i)){
				for(int k=0; k < i; k++){
					if(k == teams_done[k])
						skip = true;
				}
				if(!skip)
					best_index = team_calc_points(i);
			}
		}
		printf("INDEX END: %d\n", best_index);

		printf("livetable iteration: %d\n", i);
		strcpy(w.teams[i], md.teams[best_index].name);
		printf("begin entry name: %s\n", w.teams[i]);
		w.points[i] = team_calc_points(best_index);
		printf("begin entry point: %d\n", w.points[i]);
		w.games_played[i] = team_calc_games_played(best_index);
		printf("begin entry games played: %d\n", w.games_played[i]);
		w.games_won[i] = team_calc_games_won(best_index);
		printf("begin entry games won: %d\n", w.games_won[i]);
		w.games_tied[i] = team_calc_games_tied(best_index);
		printf("begin entry games tied: %d\n", w.games_tied[i]);
		w.games_lost[i] = w.games_played[i] - (w.games_won[i] + w.games_tied[i]);
		printf("begin entry games lost: %d\n", w.games_lost[i]);
		w.goals[i] = team_calc_goals(best_index);
		printf("begin entry goals: %d\n", w.goals[i]);
		w.goals_taken[i] = team_calc_goals_taken(best_index);
		printf("begin entry goals taken: %d\n", w.goals[i]);
		w.color[i] = Color_from_hex(md.teams[i].color_light);

		teams_done[i] = best_index;
	}
	return w;
}

WidgetGameplan WidgetGameplan_create() {
	WidgetGameplan w;
	w.widget_num = WIDGET_GAMEPLAN + WidgetGameplan_enabled;
	w.len = md.games_count;
	for (u8 i = 0; i < md.games_count; i++){
		strcpy(w.teams1[i], md.teams[md.games[i].t1_index].name);
		strcpy(w.teams2[i], md.teams[md.games[i].t2_index].name);
		w.goals_t1[i] = 49; // TODO md.games[i].score.t1;
		w.goals_t2[i] = 49; // TODO md.games[i].score.t2;

		w.team1_color_left[i] = Color_from_hex(md.teams[md.games[i].t1_index].color_light);
		w.team1_color_right[i] = Color_from_hex(md.teams[md.games[i].t1_index].color_dark);
		w.team2_color_left[i] = Color_from_hex(md.teams[md.games[i].t2_index].color_dark);
		w.team2_color_right[i] = Color_from_hex(md.teams[md.games[i].t2_index].color_light);

		printf("%d.) %s, %d : %d ,%s\n(%s) (%s)\n", i, w.teams1[i], w.goals_t1[i], w.goals_t2[i], w.teams2[i], w.team1_color_left[i], w.team2_color_right[i]);
	}

	return w;
}

// TODO remove type bc it's redundant
WidgetCard WidgetCard_create(const u8 card_i) {
	const u8 cur = md.cur.gameindex;

	WidgetCard w;
	// TODO NOW when to despawn cards?
	w.widget_num = WIDGET_CARD_SHOW;
	strcpy(w.name, md.players[md.games[cur].cards[card_i].player_index].name);
	w.type = md.games[cur].cards[card_i].card_type;
	return w;
}

// Calculate the points of all games played so far of the team with index index.
u16 team_calc_points(u8 index) {
	u16 p = 0;
	for (u8 i = 0; i < md.games_count; i++) {
		if (md.games[i].t1_index == index) {
			if (md.games[i].score.t1 > md.games[i].score.t2)
				p += 3;
			else if (md.games[i].score.t1 == md.games[i].score.t2)
				p++;
		} else if (md.games[i].t2_index == index) {
			if (md.games[i].score.t2 > md.games[i].score.t1)
				p += 3;
			else if (md.games[i].score.t2 == md.games[i].score.t1)
				p++;
		}
	}
	return p;
}

u8 team_calc_games_played(u8 index){
	u8 p = 0;
	for (u8 i = 0; i < md.games_count; i++)
		if (md.games[i].t1_index == index || md.games[i].t2_index == index)
			p++;
	return p;
}

u8 team_calc_games_won(u8 index){
	u8 p = 0;
	for (u8 i = 0; i < md.games_count; i++) {
		if (md.games[i].t1_index == index && md.games[i].score.t1 > md.games[i].score.t2)
			p++;
		else if (md.games[i].t2_index == index && md.games[i].score.t2 > md.games[i].score.t1)
			p++;
	}
	return p;
}

u8 team_calc_games_tied(u8 index){
	u8 p = 0;
	for (u8 i = 0; i < md.games_count; i++) {
		if (md.games[i].t1_index == index && md.games[i].score.t1 == md.games[i].score.t2)
			p++;
		else if (md.games[i].t2_index == index && md.games[i].score.t2 == md.games[i].score.t1)
			p++;
	}
	return p;
}

u16 team_calc_goals(u8 index){
	u16 p = 0;
	for (u8 i = 0; i < md.games_count; i++) {
		if (md.games[i].t1_index == index)
			p += md.games[i].score.t1;
		else if (md.games[i].t2_index == index)
			p += md.games[i].score.t2;
	}
	return p;
}

u16 team_calc_goals_taken(u8 index){
	u16 p = 0;
	for (u8 i = 0; i < md.games_count; i++) {
		if (md.games[i].t1_index == index)
			p += md.games[i].score.t2;
		else if (md.games[i].t2_index == index)
			p += md.games[i].score.t1;
	}
	return p;
}

bool send_message_to_site(char *message) {
	if (client_con == NULL) {
		printf("client is not connected, couldnt send Message: '%s'\n", message);
		return false;
	}
	mg_ws_send(client_con, message, strlen(message), WEBSOCKET_OP_TEXT);
	return true;
}

void handle_rentnerend_btn_press(u8 *signal){
	printf("received a signal: %d", *signal);
	switch (*signal) {
		case T1_SCORE_PLUS: {
			md.games[md.cur.gameindex].score.t1++;
			printf("New T1 score: %d\n", md.games[md.cur.gameindex].score.t1);
			break;
		}
		case T1_SCORE_MINUS: {
			if(md.games[md.cur.gameindex].score.t1 > 0)
				md.games[md.cur.gameindex].score.t1--;
			break;
		}
		case T2_SCORE_PLUS: {
			md.games[md.cur.gameindex].score.t2++;
			break;
		}
		case T2_SCORE_MINUS: {
			if(md.games[md.cur.gameindex].score.t2 > 0)
				md.games[md.cur.gameindex].score.t2--;
			break;
		}
		case GAME_NEXT: {
			if(md.cur.gameindex < md.games_count-1)
				md.cur.gameindex++;
			break;
		}
		case GAME_PREV: {
			if(md.cur.gameindex > 0)
				md.cur.gameindex--;
			break;
		}
		case GAME_SWITCH_SIDES: {
			md.cur.halftime = !md.cur.halftime;
			break;
		}
		case TIME_PLUS: {
			md.cur.time++;
			break;
		}
		case TIME_MINUS: {
			if(md.cur.time > 0)
				md.cur.time--;
			break;
		}
		case TIME_TOGGLE_PAUSE: {
			md.cur.pause = !md.cur.pause;
			break;
		}
		case TIME_RESET: {
			md.cur.time = GAME_LENGTH;
			break;
		}
		default: {
			printf("WARNING: Received unknown button press from rentnerend\n");
			break;
		}

	}
}

void ev_handler(struct mg_connection *nc, int ev, void *p) {
	// TODO FINAL CONSIDER keeping these cases
	switch (ev) {
		case MG_EV_CONNECT:
			printf("New client connected!\n");
			break;
		case MG_EV_ACCEPT:
			printf("Connection accepted!\n");
			break;
		case MG_EV_CLOSE:
			printf("Client disconnected!\n");
			client_con = NULL;
			break;
		case MG_EV_HTTP_MSG: {
			struct mg_http_message *hm = p;
			mg_ws_upgrade(nc, hm, NULL);
			printf("Client upgraded to WebSocket connection!\n");
			break;
		}
		case MG_EV_WS_OPEN:
			printf("Connection opened!\n");
			client_con = nc;
			break;
		case MG_EV_WS_MSG: {
			struct mg_ws_message *m = (struct mg_ws_message *) p;
			handle_rentnerend_btn_press((u8 *)m->data.buf);
			break;
		}
		// Signals not worth logging
		case MG_EV_OPEN:
		case MG_EV_POLL:
		case MG_EV_READ:
		case MG_EV_WRITE:
		case MG_EV_HTTP_HDRS:
			break;
		default:
			printf("Ignoring unknown signal %d ...\n", ev);
	}
}

// Return the index of a players name.
// If the name does not exist, return -1.
int player_index(const char *name) {
	for (u8 i = 0; i < md.players_count; i++)
		if (!strcmp(md.players[i].name, name))
			return i;
	return -1;
}

// Return the index of a team name.
// If the name does not exist return -1.
int team_index(const char *name) {
	for (u8 i = 0; i < md.teams_count; i++)
		if (strcmp(md.teams[i].name, name) == 0)
			return i;
	return -1;
}

void load_json(const char *path) {
	// First convert path to actual string containing whole file
	FILE *f = fopen(path, "rb");
	if (f == NULL) {
		printf("Json Input file is not available! Exiting...\n");
		exit(EXIT_FAILURE);
	}
	// seek to end to find length, then reset to the beginning
	fseek(f, 0, SEEK_END);
	u32 file_size = ftell(f);
	rewind(f);

	char *filestring = malloc((file_size + 1) * sizeof(char));
	if (filestring == NULL) {
		printf("Not enough memory for loading json! Exiting...\n");
		fclose(f);
		exit(EXIT_FAILURE);
	}

	u32 chars_read = fread(filestring, sizeof(char), file_size, f);
	if (chars_read != file_size) {
		printf("Could not read whole json file! Exiting...");
		free(filestring);
		fclose(f);
		exit(EXIT_FAILURE);
	}
	filestring[file_size] = '\0';
	fclose(f);

	// Then split json into teams and games
	struct json_object *root = json_tokener_parse(filestring);
	struct json_object *teams = json_object_new_object();
	struct json_object *games = json_object_new_object();
	json_object_object_get_ex(root, "teams", &teams);
	json_object_object_get_ex(root, "games", &games);

	md.teams_count = json_object_object_length(teams);
	md.teams = malloc(md.teams_count * sizeof(Team));

	md.players_count = md.teams_count*2;
	md.players = malloc(md.players_count * sizeof(Player));

	// Read all the teams
	u32 i = 0;
	json_object_object_foreach(teams, teamname, teamdata) {
		md.teams[i].name = teamname;
		json_object *logo, *keeper, *field, *name, *color;

		json_object_object_get_ex(teamdata, "logo", &logo);
		md.teams[i].logo_filename = malloc(strlen(json_object_get_string(logo)) * sizeof(char));
		strcpy(md.teams[i].logo_filename, json_object_get_string(logo));

		json_object_object_get_ex(teamdata, "keeper", &keeper);
		json_object_object_get_ex(keeper, "name", &name);
		md.players[i*2].name = malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2].name, json_object_get_string(name));
		md.players[i*2].team_index = i;
		md.players[i*2].role = 0;
		md.teams[i].keeper_index = i*2;


		json_object_object_get_ex(teamdata, "field", &field);
		json_object_object_get_ex(field, "name", &name);
		md.players[i*2+1].name = malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2+1].name, json_object_get_string(name));
		md.players[i*2+1].team_index = i;
		md.players[i*2+1].role = 1;
		md.teams[i].field_index = i*2+1;

		json_object_object_get_ex(teamdata, "color_light", &color);
		md.teams[i].color_light = malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_light, json_object_get_string(color));

		json_object_object_get_ex(teamdata, "color_dark", &color);
		md.teams[i].color_dark = malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_dark, json_object_get_string(color));

		i++;
	}

	md.games_count = json_object_object_length(games);
	md.games = malloc(md.games_count * sizeof(Game));

	i = 0;
	json_object_object_foreach(games, gamenumber, gamedata) {
		json_object *team;
		json_object_object_get_ex(gamedata, "team1", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 1 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t1_index = team_index(json_object_get_string(team));

		json_object_object_get_ex(gamedata, "team2", &team);
		if (team_index(json_object_get_string(team)) == -1) {
			printf("Erorr parsing JSON: '%s' does not exist (teamname of Team 2 in Game %d). Exiting...\n", json_object_get_string(team), i + 1);
			exit(EXIT_FAILURE);
		}
		md.games[i].t2_index = team_index(json_object_get_string(team));
		json_object *halftimescore, *score, *cards, *var;
		if (json_object_object_get_ex(gamedata, "halftimescore", &halftimescore)) {
			json_object_object_get_ex(halftimescore, "team1", &var);
			md.games[i].halftimescore.t1 = json_object_get_int(var);
			json_object_object_get_ex(halftimescore, "team2", &var);
			md.games[i].halftimescore.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(gamedata, "score", &score)) {
			json_object_object_get_ex(score, "team1", &var);
			md.games[i].score.t1 = json_object_get_int(var);
			json_object_object_get_ex(score, "team2", &var);
			md.games[i].score.t2 = json_object_get_int(var);
		}
		if (json_object_object_get_ex(gamedata, "cards", &cards)) {

			md.games[i].cards_count = json_object_object_length(cards);
			md.games[i].cards = malloc(md.games[i].cards_count * sizeof(Card));

			u32 j = 0;
			json_object_object_foreach(cards, cardname, carddata) {
				json_object *player, *type;
				json_object_object_get_ex(carddata, "player", &player);
				if (player_index(json_object_get_string(player)) == -1) {
					printf("Erorr parsing JSON: '%s' does not exist (Playername of Card %d in Game %d). Exiting...\n", json_object_get_string(player), j+1, i + 1);
				}
				md.games[i].cards[j].player_index = player_index(json_object_get_string(player));

				json_object_object_get_ex(carddata, "type", &type);
				md.games[i].cards[j].card_type = json_object_get_boolean(type);
				j++;
			}
		}
		i++;
	}
}

//@ret 1 if everything worked, 0 if it couldnt open one of the files
bool copy_file(const char *source, const char *destination) {
	FILE *src = fopen(source, "rb");
	if (!src) {
		perror("Error opening source file");
		return false;
	}

	FILE *dest = fopen(destination, "wb");
	if (!dest) {
		perror("Error opening destination file");
		fclose(src);
		return false;
	}

	// Directly copy the content
	char ch;
	while ((ch = fgetc(src)) != EOF) {
		fputc(ch, dest);
	}

	fclose(src);
	fclose(dest);
	return true;
}


//@ret 1 if everything worked, 0 if there was any kind of error (e.g. cant write to file)
bool save_json(char *path) {
	// TODO FILE *f = fopen(path, "w+");
	return true;
}



// Set current_match to first match
// TODO
void init_matchday() {
	if (md.games_count == 0) {
		printf("There are no games, exiting\n");
		exit(EXIT_FAILURE);
	}
	md.cur.gameindex = 0;
	md.cur.halftime = 0;
	md.cur.pause = true;
	md.cur.time = GAME_LENGTH;
	for (u8 i = 0; i < md.games_count; i++) {
		md.games[i].halftimescore.t1 = 0;
		md.games[i].halftimescore.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
}


u8 add_card(enum CardType type) {
	const u8 cur = md.cur.gameindex;

	if (md.games[cur].cards_count == 0)
		md.games[cur].cards = malloc(0 + 1 * sizeof(Card));
	else
		md.games[cur].cards = realloc(md.games[cur].cards, (md.games[cur].cards_count+1) * sizeof(Card));
	printf("Select player:\n1. %s (Keeper %s)\n2. %s (Field %s)\n3. %s (Keeper %s)\n4. %s (Field %s)\n",
		md.players[md.teams[md.games[cur].t1_index].keeper_index].name, md.teams[md.games[cur].t1_index].name,
		md.players[md.teams[md.games[cur].t1_index].field_index].name, md.teams[md.games[cur].t1_index].name,
		md.players[md.teams[md.games[cur].t2_index].keeper_index].name, md.teams[md.games[cur].t2_index].name,
		md.players[md.teams[md.games[cur].t2_index].field_index].name, md.teams[md.games[cur].t2_index].name);

	char ch;
	u8 player_i = 0;
	while (!player_i) {
		ch = getchar();
		switch(ch) {
			case '1':
				player_i = md.teams[md.games[cur].t1_index].keeper_index;
				printf("TODO chose '%s'\n", md.players[player_i].name);
				break;
			case '2':
				player_i = md.teams[md.games[cur].t1_index].field_index;
				break;
			case '3':
				player_i = md.teams[md.games[cur].t2_index].keeper_index;
				break;
			case '4':
				player_i = md.teams[md.games[cur].t2_index].field_index;
				break;
		}
	}
	md.games[cur].cards[md.games[cur].cards_count].player_index = player_i;
	md.games[cur].cards[md.games[cur].cards_count++].card_type = type;
	return md.games[cur].cards_count - 1;
}

void *mongoose_update() {
	while (running) mg_mgr_poll(&mgr, 100);
	return NULL;
}

int main(void) {
	// WebSocket stuff
	mg_mgr_init(&mgr);
	mg_http_listen(&mgr, URL, ev_handler, NULL);
	pthread_t thread;
	if (pthread_create(&thread, NULL, mongoose_update, NULL) != 0) {
		fprintf(stderr, "ERROR: Failed to create thread for updating the connection!");
		goto cleanup;
	}

	// User data stuff
	load_json(JSON_PATH);
	init_matchday();

	printf("Server loaded!\n");

	while (running) {
		char c = getchar();
		switch (c) {
			case SET_TIME: {
				u16 min; u8 sec;
				printf("Current time: %d:%2d\nNew time (in MM:SS): ", md.cur.time/60, md.cur.time%60);
				scanf("%hu:%hhu", &min, &sec);
				md.cur.time = min*60 + sec;
				printf("New current time: %d:%2d\n", md.cur.time/60, md.cur.time%60);

				u8 buffer[3];
				buffer[0] = SCOREBOARD_SET_TIMER;
				u16 time = htons(md.cur.time);
				memcpy(&buffer[1], &time, sizeof(time));
				mg_ws_send(client_con, buffer, sizeof(buffer), WEBSOCKET_OP_BINARY);
				break;
			}
			case PAUSE_TIME: {
				// TODO NOW
				const u8 data = SCOREBOARD_PAUSE_TIMER;
				mg_ws_send(client_con, &data, sizeof(u8), WEBSOCKET_OP_BINARY);
				break;
			}
			/*
		case ADD_SECOND: {
			md.cur.time++;
			printf("Added 1s, new time: %d:%d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		case REMOVE_SECOND: {
			md.cur.time--;
			printf("Removed 1s, new time: %d:%d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		*/
			case GAME_FORWARD:
				if (md.cur.gameindex == md.games_count - 1) {
					printf("Already at last game! Doing nothing ...\n");
					break;
				}
				md.cur.gameindex++;
				md.cur.halftime = 0;
				md.cur.time = GAME_LENGTH;
				printf(
					"New same %d: %s vs. %s\n",
					md.cur.gameindex + 1,
					md.teams[md.games[md.cur.gameindex].t1_index].name,
					md.teams[md.games[md.cur.gameindex].t2_index].name
				);

				WidgetScoreboard data = WidgetScoreboard_create();
				data.widget_num = WIDGET_SCOREBOARD + 1;
				memcpy(data.team1, md.teams[md.games[md.cur.gameindex].t1_index].name, TEAMS_NAME_MAX_LEN);
				memcpy(data.team2, md.teams[md.games[md.cur.gameindex].t2_index].name, TEAMS_NAME_MAX_LEN);
				mg_ws_send(client_con, &data, sizeof(WidgetScoreboard), WEBSOCKET_OP_BINARY);

				break;
			case GAME_BACK: {
				if (md.cur.gameindex == 0) {
					printf("Already at first game! Doing nothing ...\n");
					break;
				}
				md.cur.gameindex--;
				md.cur.halftime = 0;
				md.cur.time = GAME_LENGTH;
				printf(
					"New game (%d): '%s' vs. '%s'\n",
					md.cur.gameindex+1,
					md.teams[md.games[md.cur.gameindex].t1_index].name,
					md.teams[md.games[md.cur.gameindex].t2_index].name
				);

				WidgetScoreboard w = WidgetScoreboard_create();
				w.widget_num = WIDGET_SCOREBOARD + 1;
				memcpy(w.team1, md.teams[md.games[md.cur.gameindex].t1_index].name, TEAMS_NAME_MAX_LEN);
				memcpy(w.team2, md.teams[md.games[md.cur.gameindex].t2_index].name, TEAMS_NAME_MAX_LEN);
				printf("Currently playing: '%s' vs. '%s'\n", w.team1, w.team2);
				const char *data = (char *) &w;
				mg_ws_send(client_con, data, sizeof(WidgetScoreboard), WEBSOCKET_OP_BINARY);

				break;
			}
			case GAME_HALFTIME:
				// TODO WIP
				printf("Now in halftime %d!\n", md.cur.halftime + 1);
				md.cur.halftime = !md.cur.halftime;
				WidgetScoreboard ws = WidgetScoreboard_create();
				send_widget(&ws);
				break;
			case GOAL_TEAM_1:
				md.games[md.cur.gameindex].score.t1++;
				printf(
					"New score: %d : %d\n",
					md.games[md.cur.gameindex].score.t1,
					md.games[md.cur.gameindex].score.t2
				);
				WidgetGameplan wg1 = WidgetGameplan_create();
				send_widget(&wg1);
				break;
			case GOAL_TEAM_2:
				md.games[md.cur.gameindex].score.t2++;
				printf(
					"New score: %d : %d\n",
					md.games[md.cur.gameindex].score.t1,
					md.games[md.cur.gameindex].score.t2
				);
				WidgetGameplan wg2 = WidgetGameplan_create();
				send_widget(&wg2);
				break;
			case REMOVE_GOAL_TEAM_1:
				if (md.games[md.cur.gameindex].score.t1 > 0)
					--md.games[md.cur.gameindex].score.t1;
				printf(
					"New score: %d : %d\n",
					md.games[md.cur.gameindex].score.t1,
					md.games[md.cur.gameindex].score.t2
				);
				break;
			case REMOVE_GOAL_TEAM_2:
				if (md.games[md.cur.gameindex].score.t2 > 0)
					--md.games[md.cur.gameindex].score.t2;
				printf(
					"New score: %d : %d\n",
					md.games[md.cur.gameindex].score.t1,
					md.games[md.cur.gameindex].score.t2
				);
				break;
			case DEAL_YELLOW_CARD:{
				WidgetCard wy = WidgetCard_create(add_card(YELLOW));
				send_widget(&wy);
				break;
			}
			case DEAL_RED_CARD: {
				WidgetCard wr = WidgetCard_create(add_card(RED));
				send_widget(&wr);
				break;
			}
			case DELETE_CARD: {
				u32 cur_i = md.cur.gameindex;
				for (u32 i = 0; i < md.games[cur_i].cards_count; i++) {
					printf("%d. ", i + 1);
					if (md.games[cur_i].cards[i].card_type == 0)
						printf("Y ");
					else
						printf("R ");
					printf("%s , %s ", md.players[md.games[cur_i].cards[i].player_index].name,
			md.teams[md.players[md.games[cur_i].cards[i].player_index].team_index].name);
					if (md.players[md.games[cur_i].cards[i].player_index].role == 0)
						printf("(Keeper)\n");
					else
						printf("(field)\n");
				}
				printf("Select a card to delete: ");
				u32 c = 0;
				scanf("%ud", &c);
				// Overwrite c with the last element
				md.games[cur_i].cards[c-1] = md.games[cur_i].cards[--md.games[cur_i].cards_count];
				printf("Cards remaining:\n");
				for (u32 i = 0; i < md.games[cur_i].cards_count; i++) {
					printf("%d. ", i + 1);
					if (md.games[cur_i].cards[i].card_type == 0)
						printf("Y ");
					else
						printf("R ");
					printf("%s , %s ", md.players[md.games[cur_i].cards[i].player_index].name,
			md.teams[md.players[md.games[cur_i].cards[i].player_index].team_index].name);
					if (md.players[md.games[cur_i].cards[i].player_index].role == 0)
						printf("(Keeper)\n");
					else
						printf("(field)\n");
				}
				break;
			}
			// #### UI STUFF
			case TOGGLE_WIDGET_SCOREBOARD:
				WidgetScoreboard_enabled = !WidgetScoreboard_enabled;
				WidgetScoreboard wscore = WidgetScoreboard_create();
				send_widget(&wscore);
				break;
			/*
		case TOGGLE_WIDGET_HALFTIME:
			widget_halftime_enabled = !widget_halftime_enabled;
			send_widget_halftime(widget_halftime_create());
			break;
		*/
			case TOGGLE_WIDGET_LIVETABLE:
				WidgetLivetable_enabled = !WidgetLivetable_enabled;
				WidgetLivetable wlive = WidgetLivetable_create();
				send_widget(&wlive);
				break;
			case TOGGLE_WIDGET_GAMEPLAN:
				WidgetGameplan_enabled = !WidgetGameplan_enabled;
				WidgetGameplan wgame = WidgetGameplan_create();
				send_widget(&wgame);
				break;
			case TOGGLE_WIDGET_GAMESTART:
				WidgetGamestart_enabled = !WidgetGamestart_enabled;
				WidgetGamestart wspiel = WidgetGamestart_create();
				send_widget(&wspiel);
				break;
			case RELOAD_JSON:
				printf("TODO: RELOAD_JSON\n");
				break;
			case PRINT_HELP:
				printf(
					"======= Keyboard options =======\n"
					"n  Game Forward\n"
					"p  Game Back\n"
					"h  Game Halftime\n"
					"\n"
					"1  Goal Team 1\n"
					"2  Goal Team 2\n"
					"3  Remove Goal Team 1\n"
					"4  Remove Goal Team 2\n"
					"\n"
					"y  Yellow Card\n"
					"r  Red Card\n"
					"d  Delete Card\n"
					"\n"
					"i  Toggle Widget: Scoreboard\n"
					"l  Toggle Widget: Livetable\n"
					"v  Toggle Widget: Gameplan\n"
					"s  Toggle Widget: Spielstart\n"
					"\n"
					"t  set timer\n"
					"=  pause/resume timer\n"
					"\n"
					"(j  Reload JSON)\n"
					"?  print help\n"
					"q  quit\n"
					"================================\n"
				);
				break;
			case EXIT:
				printf("TODO: about to quit\n");
				running = false;
				break;
			case TEST: {
				// TODO FINAL REMOVE ig
				char string[40];
				sprintf(string, "Du bist eine");
				send_message_to_site(string);
				break;
			}
		}
	}

	// WebSocket stuff, again
	if (pthread_join(thread, NULL) != 0)
		fprintf(stderr, "ERROR: Failed to join thread!\n");
	printf("TODO joined thread\n");

cleanup:
	mg_mgr_free(&mgr);
	return 0;
}
