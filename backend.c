#include <stdbool.h>
#include <time.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
#include "mongoose/mongoose.h"

#include "config.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

// #### Javascript/ GUI Widgets Structs

//The first element is disable, the second is enable/update
enum widgets {
	WIDGET_SCOREBOARD = 1,
	WIDGET_LIVETABLE = 3,
	WIDGET_GAMEPLAN = 5,
	WIDGET_SPIELSTART = 7,
	WIDGET_CARD = 9,
	// TODO
	SCOREBOARD_SET_TIMER = 11,
	// TODO WIP
	SCOREBOARD_PAUSE_TIMER = 12
};

#pragma pack(push, 1)
typedef struct {
	u8 widget_num;
	char team1[TEAMS_NAME_MAX_LEN];
	char team2[TEAMS_NAME_MAX_LEN];
	u8 score_t1;
	u8 score_t2;
	bool is_halftime;
	char team1_color_left[HEX_COLOR_LEN];
	char team1_color_right[HEX_COLOR_LEN];
	char team2_color_left[HEX_COLOR_LEN];
	char team2_color_right[HEX_COLOR_LEN];
} widget_scoreboard;

typedef struct {
	u8 widget_num;
	char team1_keeper[TEAMS_NAME_MAX_LEN];
	char team1_field[TEAMS_NAME_MAX_LEN];
	char team2_keeper[TEAMS_NAME_MAX_LEN];
	char team2_field[TEAMS_NAME_MAX_LEN];
	char team1_color_left[HEX_COLOR_LEN];
	char team1_color_right[HEX_COLOR_LEN];
	char team2_color_left[HEX_COLOR_LEN];
	char team2_color_right[HEX_COLOR_LEN];
} widget_spielstart;

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
} widget_livetable;

typedef struct {
	u8 widget_num;
	u8 len; // amount of Games total
	char teams1[GAMES_COUNT_MAX][TEAMS_NAME_MAX_LEN];
	char teams2[GAMES_COUNT_MAX][TEAMS_NAME_MAX_LEN];
	u8 goals_t1[GAMES_COUNT_MAX];
	u8 goals_t2[GAMES_COUNT_MAX];
	char team1_color_left[HEX_COLOR_LEN];
	char team1_color_right[HEX_COLOR_LEN];
	char team2_color_left[HEX_COLOR_LEN];
	char team2_color_right[HEX_COLOR_LEN];
} widget_gameplan;
#pragma pack(pop)

// #### In Game Structs

typedef struct {
	u8 t1;
	u8 t2;
} Score;

typedef struct {
	u8 player_index;
	bool card_type; // 0: yellow card, 1: red card
} Card;

typedef struct {
	char *name;
	u8 team_index;
	bool role; // 0: keeper, 1: field
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
#define YELLOW_CARD 'y'
#define RED_CARD 'r'
#define DELETE_CARD 'd'

// Widget toggling
#define TOGGLE_WIDGET_SCOREBOARD 'i'
#define TOGGLE_WIDGET_LIVETABLE 'l'
#define TOGGLE_WIDGET_GAMEPLAN 'v'
#define TOGGLE_WIDGET_SPIELSTART 's'

// Meta
#define EXIT 'q'
#define RELOAD_JSON 'j'
#define PRINT_HELP '?'

// Other
#define TEST '6'
#define WEBSOCKET_STATUS '7'


//TODO put all function definitions here
u16 team_calc_points(u8 index);
u8 team_calc_games_played(u8 index);
u8 team_calc_games_won(u8 index);
u8 team_calc_games_tied(u8 index);
u16 team_calc_goals(u8 index);
u16 team_calc_goals_taken(u8 index);

Matchday md;
// We pretty much have to do this in gloabl scope bc at least ev_handler (TODO FINAL DECIDE is this possible/better with smaller scope)
struct mg_connection *client_con = NULL;

bool widget_scoreboard_enabled = false;
bool widget_spielstart_enabled = false;
bool widget_livetable_enabled = false;
bool widget_gameplan_enabled = false;

// TODO send_widget_card(widget_card w) {
//
// }

bool send_widget_scoreboard(widget_scoreboard w) {
	if (client_con == NULL) {
		fprintf(stderr, "Client not connected, couldn't send widget!\n");
		return false;
	}
	printf("%d:%d, %d\n", w.score_t1, w.score_t2, w.is_halftime);
	const char *data = (char *) &w;
	mg_ws_send(client_con, data, sizeof(widget_scoreboard), WEBSOCKET_OP_BINARY);
	printf("Sent '%s' to client!\n", data);
	return true;
}

bool send_widget_spielstart(widget_spielstart w) {
	if (client_con == NULL) {
		printf("WARNING: client if not connected, couldnt send widget_spielstart\n");
		return false;
	}
	mg_ws_send(client_con, (char *) &w , sizeof(w), WEBSOCKET_OP_BINARY);
	return true;
}

bool send_widget_livetable(widget_livetable w) {
	printf("begin send_livetable\n");
	if (client_con == NULL) {
		printf("WARNING: client if not connected, couldnt send widget_livetable\n");
		return false;
	}
	const char *data = (char *) &w;
	mg_ws_send(client_con, data, sizeof(widget_livetable), WEBSOCKET_OP_BINARY);
	printf("Send '%s' to client!\n", data);
	return true;
}

bool send_widget_gameplan(widget_gameplan w) {
	if (client_con == NULL) {
		printf("WARNING: client if not connected, couldnt send widget_gameplan\n");
		return false;
	}
	mg_ws_send(client_con, (char *) &w, sizeof(w), WEBSOCKET_OP_BINARY);
	return true;
}

widget_scoreboard widget_scoreboard_create() {
	widget_scoreboard w;
	w.widget_num = WIDGET_SCOREBOARD + widget_scoreboard_enabled;

	if (md.cur.halftime) {
		strcpy(w.team2, md.teams[md.games[md.cur.gameindex].t1_index].name);
		strcpy(w.team1, md.teams[md.games[md.cur.gameindex].t2_index].name);
		w.score_t2 = md.games[md.cur.gameindex].score.t1;
		w.score_t1 = md.games[md.cur.gameindex].score.t2;

		strcpy(w.team1_color_left, md.teams[md.games[md.cur.gameindex].t2_index].color_light);
		strcpy(w.team1_color_right, md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
		strcpy(w.team2_color_left, md.teams[md.games[md.cur.gameindex].t1_index].color_dark);
		strcpy(w.team2_color_right, md.teams[md.games[md.cur.gameindex].t1_index].color_light);
		strcpy(w.team1_color_left, md.teams[md.games[md.cur.gameindex].t2_index].color_light);
		strcpy(w.team1_color_right, md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
	} else {
		strcpy(w.team1, md.teams[md.games[md.cur.gameindex].t1_index].name);
		strcpy(w.team2, md.teams[md.games[md.cur.gameindex].t2_index].name);
		w.score_t1 = md.games[md.cur.gameindex].score.t1;
		w.score_t2 = md.games[md.cur.gameindex].score.t2;

		strcpy(w.team1_color_left, md.teams[md.games[md.cur.gameindex].t1_index].color_light);
		strcpy(w.team1_color_right, md.teams[md.games[md.cur.gameindex].t1_index].color_dark);
		strcpy(w.team2_color_left, md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
		strcpy(w.team2_color_right, md.teams[md.games[md.cur.gameindex].t2_index].color_light);
	}

	w.is_halftime = md.cur.halftime;
	return w;
}

widget_spielstart widget_spielstart_create() {
	widget_spielstart w;
	w.widget_num = WIDGET_SPIELSTART + widget_spielstart_enabled;
	strcpy(w.team1_keeper, md.players[md.teams[md.games[md.cur.gameindex].t1_index].keeper_index].name);
	strcpy(w.team1_field, md.players[md.teams[md.games[md.cur.gameindex].t1_index].field_index].name);
	strcpy(w.team2_keeper, md.players[md.teams[md.games[md.cur.gameindex].t2_index].keeper_index].name);
	strcpy(w.team2_field, md.players[md.teams[md.games[md.cur.gameindex].t2_index].field_index].name);
	return w;
}

widget_livetable widget_livetable_create() {
	printf("begin livetable\n");
	widget_livetable w;
	w.widget_num = WIDGET_LIVETABLE + widget_livetable_enabled;
	w.len = md.teams_count;
	int teams_done[md.teams_count];
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

		printf("begin entry name: %d, %d\n", i, best_index);
		strcpy(w.teams[i], md.teams[best_index].name);
		printf("begin entry point: %d\n", i);
		w.points[i] = team_calc_points(best_index);
		printf("begin entry games played: %d\n", i);
		w.games_played[i] = team_calc_games_played(best_index);
		printf("begin entry games won: %d\n", i);
		w.games_won[i] = team_calc_games_won(best_index);
		printf("begin entry games tied: %d\n", i);
		w.games_tied[i] = team_calc_games_tied(best_index);
		printf("begin entry games lost: %d\n", i);
		w.games_lost[i] = w.games_played[i] - (w.games_won[i] + w.games_tied[i]);
		printf("begin entry goals: %d\n", i);
		w.goals[i] = team_calc_goals(best_index);

		teams_done[i] = best_index;
		printf("livetable iteration: %d\n", i);
	}
	return w;
}

widget_gameplan widget_gameplan_create() {
	widget_gameplan w;
	w.widget_num = WIDGET_GAMEPLAN + widget_gameplan_enabled;
	w.len = md.games_count;
	for (u8 i = 0; i < md.games_count; i++){
		strcpy(w.teams1[i], md.teams[md.games[i].t1_index].name);
		strcpy(w.teams2[i], md.teams[md.games[i].t2_index].name);
		w.goals_t1[i] = md.games[i].score.t1;
		w.goals_t2[i] = md.games[i].score.t2;
		printf("%d.) %s, %d : %d ,%s\n", i, w.teams1[i], w.goals_t1[i], w.goals_t2[i], w.teams2[i]);
	}

	strcpy(w.team1_color_left, md.teams[md.games[md.cur.gameindex].t1_index].color_light);
	strcpy(w.team1_color_right, md.teams[md.games[md.cur.gameindex].t1_index].color_dark);
	strcpy(w.team2_color_left, md.teams[md.games[md.cur.gameindex].t2_index].color_dark);
	strcpy(w.team2_color_right, md.teams[md.games[md.cur.gameindex].t2_index].color_light);
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

void ev_handler(struct mg_connection *nc, int ev, void *p) {
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
	case MG_EV_WS_MSG:
		printf("This server is send only! Ignoring incoming messages ...\n");
		break;
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
	return;
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

	return;
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
	md.cur.time = GAME_LENGTH;
	for (u8 i = 0; i < md.games_count; i++) {
		md.games[i].halftimescore.t1 = 0;
		md.games[i].halftimescore.t2 = 0;
		md.games[i].score.t1 = 0;
		md.games[i].score.t2 = 0;
		md.games[i].cards_count = 0;
		md.games[i].cards = NULL;
	}
	return;
}


void add_card(bool card_type) {
	u8 ind = md.cur.gameindex;
	if (md.games[ind].cards_count == 0)
		md.games[ind].cards = malloc(1 * sizeof(Card));
	else
		md.games[ind].cards = realloc(md.games[ind].cards, (md.games[ind].cards_count+1) * sizeof(Card));
	printf("Select Player:\n1. %s (Keeper %s)\n2. %s (Field %s)\n3. %s (Keeper %s)\n4. %s (Field %s)\n",
			md.players[md.teams[md.games[ind].t1_index].keeper_index].name, md.teams[md.games[ind].t1_index].name,
			md.players[md.teams[md.games[ind].t1_index].field_index].name, md.teams[md.games[ind].t1_index].name,
			md.players[md.teams[md.games[ind].t2_index].keeper_index].name, md.teams[md.games[ind].t2_index].name,
			md.players[md.teams[md.games[ind].t2_index].field_index].name, md.teams[md.games[ind].t2_index].name);
	u8 player;
	scanf("%hhu\n", &player);
	switch(player) {
	case 1:
		player = md.teams[md.games[ind].t1_index].keeper_index;
		break;
	case 2:
		player = md.teams[md.games[ind].t1_index].field_index;
		break;
	case 3:
		player = md.teams[md.games[ind].t2_index].keeper_index;
		break;
	case 4:
		player = md.teams[md.games[ind].t2_index].field_index;
		break;
	default:
		printf("Illegal input! Doing nothing");
		return;
	}

	md.games[ind].cards[md.games[ind].cards_count].player_index = player;
	md.games[ind].cards[md.games[ind].cards_count++].card_type = card_type;
	return;
}

int main(void) {
	// WebSocket stuff
	struct mg_mgr mgr;
	mg_mgr_init(&mgr);
	mg_http_listen(&mgr, URL, ev_handler, NULL);

	// User data stuff
	load_json(JSON_PATH);
	init_matchday();

	printf("Hello, world!\n");

	bool close = false;
	while (!close) {
		mg_mgr_poll(&mgr, 1000);
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

			widget_scoreboard data = widget_scoreboard_create();
			data.widget_num = WIDGET_SCOREBOARD + 1;
			memcpy(data.team1, md.teams[md.games[md.cur.gameindex].t1_index].name, TEAMS_NAME_MAX_LEN);
			memcpy(data.team2, md.teams[md.games[md.cur.gameindex].t2_index].name, TEAMS_NAME_MAX_LEN);
			mg_ws_send(client_con, &data, sizeof(widget_scoreboard), WEBSOCKET_OP_BINARY);

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

			widget_scoreboard w = widget_scoreboard_create();
			w.widget_num = WIDGET_SCOREBOARD + 1;
			memcpy(w.team1, md.teams[md.games[md.cur.gameindex].t1_index].name, TEAMS_NAME_MAX_LEN);
			memcpy(w.team2, md.teams[md.games[md.cur.gameindex].t2_index].name, TEAMS_NAME_MAX_LEN);
			printf("Currently playing: '%s' vs. '%s'\n", w.team1, w.team2);
			const char *data = (char *) &w;
			mg_ws_send(client_con, data, sizeof(widget_scoreboard), WEBSOCKET_OP_BINARY);

			break;
		}
		case GAME_HALFTIME:
			// TODO WIP
			printf("Now in halftime %d!\n", md.cur.halftime + 1);
			md.cur.halftime = !md.cur.halftime;
			send_widget_scoreboard(widget_scoreboard_create());
			break;
		case GOAL_TEAM_1:
			md.games[md.cur.gameindex].score.t1++;
			printf(
				"New score: %d : %d\n",
				md.games[md.cur.gameindex].score.t1,
				md.games[md.cur.gameindex].score.t2
			);
			send_widget_gameplan(widget_gameplan_create());
			break;
		case GOAL_TEAM_2:
			md.games[md.cur.gameindex].score.t2++;
			printf(
				"New score: %d : %d\n",
				md.games[md.cur.gameindex].score.t1,
				md.games[md.cur.gameindex].score.t2
			);
			send_widget_gameplan(widget_gameplan_create());
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
		case YELLOW_CARD:
			add_card(0);
			break;
		case RED_CARD:
			add_card(1);
			break;
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
			widget_scoreboard_enabled = !widget_scoreboard_enabled;
			send_widget_scoreboard(widget_scoreboard_create());
			break;
		/*
		case TOGGLE_WIDGET_HALFTIME:
			widget_halftime_enabled = !widget_halftime_enabled;
			send_widget_halftime(widget_halftime_create());
			break;
		*/
		case TOGGLE_WIDGET_LIVETABLE:
			widget_livetable_enabled = !widget_livetable_enabled;
			send_widget_livetable(widget_livetable_create());
			break;
		case TOGGLE_WIDGET_GAMEPLAN:
			widget_gameplan_enabled = !widget_gameplan_enabled;
			send_widget_gameplan(widget_gameplan_create());
			break;
		case TOGGLE_WIDGET_SPIELSTART:
			widget_spielstart_enabled = !widget_spielstart_enabled;
			send_widget_spielstart(widget_spielstart_create());
			break;
		// #### Debug Stuff
		case EXIT:
			close = true;
			break;
		case RELOAD_JSON:
			printf("TODO: RELOAD_JSON\n");
			break;
		case PRINT_HELP:
			printf(
				"======= Keyboard options =======\n"
				"n  Game Forward\n"
				"p  Game Back\n"
				"h  Game Halftime\n\n"
				"1  Goal Team 1\n"
				"2  Goal Team 2\n"
				"3  Remove Goal Team 1\n"
				"4  Remove Goal Team 2\n\n"
				"y  Yellow Card\n"
				"r  Red Card\n"
				"d  Delete Card\n\n"
				"i  Toggle Widget: Scoreboard\n"
				"l  Toggle Widget: Livetable\n"
				"v  Toggle Widget: Gameplan\n"
				"s  Toggle Widget: Spielstart\n\n"
				"t  set timer\n"
				"=  pause/resume timer\n\n"
				"7  load/reload server connection\n"
				"(j  Reload JSON)\n"
				"?  print help\n"
				"q  quit\n"
				"================================\n"
			);
			break;
		// #### ORIESNTIOERASNTEOI
		case TEST: {
			char string[40];
			sprintf(string, "Du bist eine");
			send_message_to_site(string);
			break;
		}
		case WEBSOCKET_STATUS:
			mg_mgr_poll(&mgr, 1000);
			break;
		}
	}

	mg_mgr_free(&mgr);
	return 0;
}
