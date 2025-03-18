#include <pthread.h>
#include <stdbool.h>
#include <time.h>
#include <json-c/json.h>
#include <json-c/json_object.h>
#include "mongoose/mongoose.h"

#include "config.h"
#include "common.h"

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

#pragma pack(push, 1)
typedef struct { u8 r, g, b; } Color;

typedef struct {
	u8 widget_num;
	char t1[TEAM_NAME_MAX_LEN];
	char t2[TEAM_NAME_MAX_LEN];
	u8 score_t1;
	u8 score_t2;
	bool is_halftime;
	Color t1_color_left;
	Color t1_color_right;
	Color t2_color_left;
	Color t2_color_right;
} WidgetScoreboard;

typedef struct {
	u8 widget_num;
	// TODO NOW add t1 and t2 to the ._create function
	char t1[TEAM_NAME_MAX_LEN];
	char t2[TEAM_NAME_MAX_LEN];
	char t1_keeper[PLAYER_NAME_MAX_LEN];
	char t1_field[PLAYER_NAME_MAX_LEN];
	char t2_keeper[PLAYER_NAME_MAX_LEN];
	char t2_field[PLAYER_NAME_MAX_LEN];
	Color t1_color_left;
	Color t1_color_right;
	Color t2_color_left;
	Color t2_color_right;
} WidgetGamestart;

typedef struct {
	u8 widget_num;
	u8 len; // amount of teams total
	char teams[TEAMS_COUNT_MAX][TEAM_NAME_MAX_LEN]; // sorted
	u8 points[TEAMS_COUNT_MAX];
	u8 games_played[TEAMS_COUNT_MAX];
	u8 games_won[TEAMS_COUNT_MAX];
	u8 games_tied[TEAMS_COUNT_MAX];
	u8 games_lost[TEAMS_COUNT_MAX];
	u16 goals[TEAMS_COUNT_MAX];
	u16 goals_taken[TEAMS_COUNT_MAX];
	Color color_light[TEAMS_COUNT_MAX];
	Color color_dark[TEAMS_COUNT_MAX];
} WidgetLivetable;

typedef struct {
	u8 widget_num;
	u8 len; // total amount of games
	u8 cur; // current game
	char teams_1[GAMES_COUNT_MAX][TEAM_NAME_MAX_LEN];
	char teams_2[GAMES_COUNT_MAX][TEAM_NAME_MAX_LEN];
	u8 goals_t1[GAMES_COUNT_MAX];
	u8 goals_t2[GAMES_COUNT_MAX];
	Color t1_color_left[GAMES_COUNT_MAX];
	Color t1_color_right[GAMES_COUNT_MAX];
	Color t2_color_left[GAMES_COUNT_MAX];
	Color t2_color_right[GAMES_COUNT_MAX];
} WidgetGameplan;

typedef struct {
	u8 widget_num;
	enum CardType type;
	char name[PLAYER_NAME_MAX_LEN];
} WidgetCard;
#pragma pack(pop)

// Justice system
#define DEAL_YELLOW_CARD 'y'
#define DEAL_RED_CARD 'r'
#define DELETE_CARD 'd'

// Widget toggling
#define TOGGLE_WIDGET_SCOREBOARD 'i'
#define TOGGLE_WIDGET_LIVETABLE 'l'
#define TOGGLE_WIDGET_GAMEPLAN 'g'
#define TOGGLE_WIDGET_GAMESTART 's'

// Meta
#define EXIT 'q'
#define RELOAD_RENTNERJSON 'j'
#define PRINT_HELP '?'

#define URL "http://0.0.0.0:8081"

//TODO put all function definitions here
u16 team_calc_points(u8 index);
u8 team_calc_games_played(u8 index);
u8 team_calc_games_won(u8 index);
u8 team_calc_games_tied(u8 index);
u16 team_calc_goals(u8 index);
u16 team_calc_goals_taken(u8 index);

Matchday md;
bool running = true;
// We pretty much have to do this in gloabl scope bc at least ev_handler (TODO FINAL DECIDE is this possible/better with smaller scope)
struct mg_connection *c_front = NULL;
struct mg_connection *c_rentner = NULL;
struct mg_mgr mgr;

bool WidgetScoreboard_enabled = false;
bool WidgetGamestart_enabled = false;
bool WidgetLivetable_enabled = false;
bool WidgetGameplan_enabled = false;

// Converts '0'-'9', 'a'-'f', 'A'-'F' to 0-15.
u8 hex_char_to_int(const char c) {
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
	return *(int*)p1 - *(int*)p2;
}

int teams_sort_after_name(const void *p1, const void *p2){
	return strcmp(((Team *)p1)->name, ((Team *)p2)->name);
}

int teams_sort_after_goals(const void *p1, const void *p2){
	u8 t1_goals = team_calc_goals(md.players[((Team *)p1)->keeper_index].team_index);
	u8 t2_goals = team_calc_goals(md.players[((Team *)p2)->keeper_index].team_index);
	//reverse it, because bigger is better
	return t2_goals - t1_goals;
}

int teams_sort_after_goalratio(const void *p1, const void *p2){
	u8 t1_goals = team_calc_goals(md.players[((Team *)p1)->keeper_index].team_index);
	u8 t2_goals = team_calc_goals(md.players[((Team *)p2)->keeper_index].team_index);
	u8 t1_goals_taken = team_calc_goals_taken(md.players[((Team *)p1)->keeper_index].team_index);
	u8 t2_goals_taken = team_calc_goals_taken(md.players[((Team *)p2)->keeper_index].team_index);
	//reverse it, because bigger is better
	return (t2_goals-t2_goals_taken) - (t1_goals-t1_goals_taken);
}

int teams_sort_after_points(const void *p1, const void *p2){
	u8 t1_points = team_calc_points(md.players[((Team *)p1)->keeper_index].team_index);
	u8 t2_points = team_calc_points(md.players[((Team *)p2)->keeper_index].team_index);
	//reverse it, because bigger is better
	return t2_points - t1_points;
}

void send_widget(void *w, size_t size) {
	if (c_front == NULL){
		fprintf(stderr, "ERROR: Client not connected, couldn't send widget!\n");
		return;
	}
	mg_ws_send(c_front, (char *) w, size, WEBSOCKET_OP_BINARY);
}

WidgetScoreboard WidgetScoreboard_create() {
	const u8 cur = md.cur.gameindex;

	WidgetScoreboard w;
	w.widget_num = WIDGET_SCOREBOARD + WidgetScoreboard_enabled;

	if (md.cur.halftime) {
		strcpy(w.t1, md.teams[md.games[cur].t1_index].name);
		strcpy(w.t2, md.teams[md.games[cur].t2_index].name);
		w.score_t1 = md.games[cur].score.t1;
		w.score_t2 = md.games[cur].score.t2;

		w.t1_color_left = Color_from_hex(md.teams[md.games[cur].t1_index].color_light);
		w.t1_color_right = Color_from_hex(md.teams[md.games[cur].t1_index].color_dark);
		w.t2_color_left = Color_from_hex(md.teams[md.games[cur].t2_index].color_dark);
		w.t2_color_right = Color_from_hex(md.teams[md.games[cur].t2_index].color_light);
	} else {
		strcpy(w.t1, md.teams[md.games[cur].t2_index].name);
		strcpy(w.t2, md.teams[md.games[cur].t1_index].name);
		w.score_t1 = md.games[cur].score.t2;
		w.score_t2 = md.games[cur].score.t1;

		w.t1_color_left = Color_from_hex(md.teams[md.games[cur].t2_index].color_light);
		w.t1_color_right = Color_from_hex(md.teams[md.games[cur].t2_index].color_dark);
		w.t2_color_left = Color_from_hex(md.teams[md.games[cur].t1_index].color_dark);
		w.t2_color_right = Color_from_hex(md.teams[md.games[cur].t1_index].color_light);
	}

	w.is_halftime = md.cur.halftime;
	return w;
}

WidgetGamestart WidgetGamestart_create() {
	const u8 cur = md.cur.gameindex;

	WidgetGamestart w;
	w.widget_num = WIDGET_GAMESTART + WidgetGamestart_enabled;
	strcpy(w.t1, md.teams[md.games[cur].t2_index].name);
	strcpy(w.t2, md.teams[md.games[cur].t1_index].name);
	strcpy(w.t1_keeper, md.players[md.teams[md.games[cur].t2_index].keeper_index].name);
	strcpy(w.t1_field, md.players[md.teams[md.games[cur].t2_index].field_index].name);
	strcpy(w.t2_keeper, md.players[md.teams[md.games[cur].t1_index].keeper_index].name);
	strcpy(w.t2_field, md.players[md.teams[md.games[cur].t1_index].field_index].name);

	w.t1_color_left = Color_from_hex(md.teams[md.games[cur].t2_index].color_light);
	w.t2_color_left = Color_from_hex(md.teams[md.games[cur].t1_index].color_light);
	w.t1_color_right = Color_from_hex(md.teams[md.games[cur].t2_index].color_dark);
	w.t2_color_right = Color_from_hex(md.teams[md.games[cur].t1_index].color_dark);

	return w;
}

WidgetLivetable WidgetLivetable_create() {
	WidgetLivetable w;
	w.widget_num = WIDGET_LIVETABLE + WidgetLivetable_enabled;
	w.len = md.teams_count;
	Team teams[md.teams_count];
	memcpy(teams, md.teams, sizeof(Team) * md.teams_count);
	merge_sort(teams, md.teams_count, sizeof(Team), teams_sort_after_name);
	merge_sort(teams, md.teams_count, sizeof(Team), teams_sort_after_goals);
	merge_sort(teams, md.teams_count, sizeof(Team), teams_sort_after_goalratio);
	merge_sort(teams, md.teams_count, sizeof(Team), teams_sort_after_points);

	for(u8 i = 0; i < md.teams_count; i++){
		u8 teamindex = md.players[teams[i].keeper_index].team_index;
		strcpy(w.teams[i], md.teams[teamindex].name);
		w.points[i] = team_calc_points(teamindex);
		w.games_played[i] = team_calc_games_played(teamindex);
		w.games_won[i] = team_calc_games_won(teamindex);
		w.games_tied[i] = team_calc_games_tied(teamindex);
		w.games_lost[i] = w.games_played[i] - (w.games_won[i] + w.games_tied[i]);
		w.goals[i] = team_calc_goals(teamindex);
		w.goals_taken[i] = team_calc_goals_taken(teamindex);
		w.color_light[i] = Color_from_hex(teams[i].color_light);
		w.color_dark[i] = Color_from_hex(teams[i].color_dark);
	}

	return w;
}

WidgetGameplan WidgetGameplan_create() {
	WidgetGameplan w;
	w.widget_num = WIDGET_GAMEPLAN + WidgetGameplan_enabled;
	w.len = md.games_count;
	w.cur = md.cur.gameindex;
	if(md.cur.gameindex == md.games_count)
		w.cur--;
	for (u8 i = 0; i < md.games_count; i++){
		strcpy(w.teams_1[i], md.teams[md.games[i].t2_index].name);
		strcpy(w.teams_2[i], md.teams[md.games[i].t1_index].name);
		w.goals_t1[i] = md.games[i].score.t2;
		w.goals_t2[i] = md.games[i].score.t1;

		w.t1_color_left[i] = Color_from_hex(md.teams[md.games[i].t2_index].color_light);
		w.t1_color_right[i] = Color_from_hex(md.teams[md.games[i].t2_index].color_dark);
		w.t2_color_left[i] = Color_from_hex(md.teams[md.games[i].t1_index].color_dark);
		w.t2_color_right[i] = Color_from_hex(md.teams[md.games[i].t1_index].color_light);
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
	for (u8 i = 0; i < md.cur.gameindex; i++) {
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
	for (u8 i = 0; i < md.cur.gameindex; i++)
		if (md.games[i].t1_index == index || md.games[i].t2_index == index)
			p++;
	return p;
}

u8 team_calc_games_won(u8 index){
	u8 p = 0;
	for (u8 i = 0; i < md.cur.gameindex; i++) {
		if (md.games[i].t1_index == index && md.games[i].score.t1 > md.games[i].score.t2)
			p++;
		else if (md.games[i].t2_index == index && md.games[i].score.t2 > md.games[i].score.t1)
			p++;
	}
	return p;
}

u8 team_calc_games_tied(u8 index){
	u8 p = 0;
	for (u8 i = 0; i < md.cur.gameindex; i++) {
		if (md.games[i].t1_index == index && md.games[i].score.t1 == md.games[i].score.t2)
			p++;
		else if (md.games[i].t2_index == index && md.games[i].score.t2 == md.games[i].score.t1)
			p++;
	}
	return p;
}

u16 team_calc_goals(u8 index){
	u16 p = 0;
	for (u8 i = 0; i < md.cur.gameindex; i++) {
		if (md.games[i].t1_index == index)
			p += md.games[i].score.t1;
		else if (md.games[i].t2_index == index)
			p += md.games[i].score.t2;
	}
	return p;
}

u16 team_calc_goals_taken(u8 index){
	u16 p = 0;
	for (u8 i = 0; i < md.cur.gameindex; i++) {
		if (md.games[i].t1_index == index)
			p += md.games[i].score.t2;
		else if (md.games[i].t2_index == index)
			p += md.games[i].score.t1;
	}
	return p;
}

void send_message_to_site(char *message) {
	if (c_front == NULL) {
		printf("client is not connected, couldnt send Message: '%s'\n", message);
		return;
	}
	mg_ws_send(c_front, message, strlen(message), WEBSOCKET_OP_TEXT);
}

void send_time(u16 t){
	if(c_front == NULL){
		printf("client is not connected, couldnt send time\n");
		return;
	}
	u8 buffer[3];
	buffer[0] = SCOREBOARD_SET_TIMER;
	u16 time = htons(t);
	memcpy(&buffer[1], &time, sizeof(time));
	mg_ws_send(c_front, buffer, sizeof(buffer), WEBSOCKET_OP_BINARY);
}

void send_time_pause(bool pause) {
	if(c_front == NULL){
		printf("client is not connected, couldnt send time\n");
		return;
	}
	u8 buffer[2];
	buffer[0] = SCOREBOARD_PAUSE_TIMER;
	buffer[1] = pause;
	mg_ws_send(c_front, &buffer, sizeof(u8)*2, WEBSOCKET_OP_BINARY);
}

void resend_widgets() {
	printf("Start resending widgets: %s\n", gettimems());
	WidgetScoreboard w_scoreboard = WidgetScoreboard_create();
	WidgetGamestart w_gamestart = WidgetGamestart_create();
	WidgetLivetable w_livetable = WidgetLivetable_create();
	WidgetGameplan w_gameplan = WidgetGameplan_create();

	send_widget(&w_scoreboard, sizeof(WidgetScoreboard));
	send_widget(&w_gamestart, sizeof(WidgetGamestart));
	send_widget(&w_livetable, sizeof(WidgetLivetable));
	send_widget(&w_gameplan, sizeof(WidgetGameplan));

	if(md.cur.pause){
		printf("pause: %d\n", md.cur.time);
		send_time(md.cur.time);
	} else {
		send_time(md.cur.time - (time(NULL) - md.cur.timestart));
		printf("pause: %ld\n", md.cur.time - (time(NULL) - md.cur.timestart));
	}
	//if(md.cur.time == md.deftime)
//		send_time(md.deftime);
	send_time_pause(md.cur.pause);
	printf("End resending widgets: %s\n", gettimems());
}

void handle_rentnerend_btn_press(u8 *signal){
	printf("Start handling btn press: %s\n", gettimems());
	printf("received a signal: %d\n", *signal);
	switch (*signal) {
		case T1_SCORE_PLUS: {
			md.games[md.cur.gameindex].score.t1++;
			printf("New T1 score (+1): %d\n", md.games[md.cur.gameindex].score.t1);
			break;
		}
		case T1_SCORE_MINUS: {
			if(md.games[md.cur.gameindex].score.t1 > 0)
				md.games[md.cur.gameindex].score.t1--;
			printf("New T1 score (-1): %d\n", md.games[md.cur.gameindex].score.t1);
			break;
		}
		case T2_SCORE_PLUS: {
			md.games[md.cur.gameindex].score.t2++;
			printf("New T2 score (+1): %d\n", md.games[md.cur.gameindex].score.t2);
			break;
		}
		case T2_SCORE_MINUS: {
			if(md.games[md.cur.gameindex].score.t2 > 0)
				md.games[md.cur.gameindex].score.t2--;
			printf("New T2 score (-1): %d\n", md.games[md.cur.gameindex].score.t2);
			break;
		}
		case GAME_NEXT: {
			if(md.cur.gameindex < md.games_count)
				md.cur.gameindex++;
			if(md.cur.gameindex == md.games_count)
				WidgetScoreboard_enabled = false;
			break;
		}
		case GAME_PREV: {
			if(md.cur.gameindex > 0)
				md.cur.gameindex--;
			break;
		}
		case GAME_SWITCH_SIDES: {
			md.cur.halftime = !md.cur.halftime;
			printf("New Half %d: %s : %s\n", md.cur.halftime,
			        md.teams[md.games[md.cur.gameindex].t1_index].name,
			        md.teams[md.games[md.cur.gameindex].t2_index].name);
			break;
		}
		case TIME_PLUS: {
			md.cur.time++;
			printf("New Time (-1): %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		case TIME_MINUS: {
			if(md.cur.time > 0)
				md.cur.time--;
			printf("New Time (-1): %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		case TIME_PLUS_20: {
			md.cur.time += 20;
			printf("New Time (-1): %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		case TIME_MINUS_20: {
			if(md.cur.time > 19)
				md.cur.time -= 20;
			printf("New Time (-1): %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		case TIME_TOGGLE_PAUSE: {
			if(!md.cur.pause){
				md.cur.time -= time(NULL) - md.cur.timestart;
			} else {
				md.cur.timestart = time(NULL);
			}
			md.cur.pause = !md.cur.pause;
			printf("Toggling time to %d: %d:%2d\n", md.cur.pause, md.cur.time/60, md.cur.time%60);
			break;
		}
		case TIME_RESET: {
			md.cur.time = md.deftime;
			md.cur.pause = true;
			printf("Reseting Time to: %d:%2d\n", md.cur.time/60, md.cur.time%60);
			break;
		}
		default: {
			printf("WARNING: Received unknown button press from rentnerend\n");
			break;
		}
	}
	printf("Stop handling btn press: %s\n", gettimems());
	resend_widgets();
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
			c_front = NULL;
			break;
		case MG_EV_HTTP_MSG: {
			struct mg_http_message *hm = p;
			//We have to know which client is connecting (frontend/rentnerend)
			//Therefor we extract the query parameter as seen below.
			//FRONTEND URL: http://0.0.0.0:8081?client=frontend
			//RENTNEREND URL: http://0.0.0.0:8081
			//TODO FINAL make this not suck
			char client_type[20];
    		mg_http_get_var(&hm->query, "client", client_type, sizeof(client_type));
			printf("Clienttype: %s\n", client_type);
			if(!strcmp(client_type, "frontend")){
				c_front = nc;
			} else if(client_type[0] == '\0'){
				c_rentner = nc;
			} else{
				printf("ERROR: Unknown Client is trying to connect!");
				nc->is_closing = true;
				break;
			}
			//TODO check if upgrade is successfull
			mg_ws_upgrade(nc, hm, NULL);
			printf("Client upgraded to WebSocket connection!\n");
			break;
		}
		case MG_EV_WS_OPEN:
			printf("Connection opened!\n");
			//c_front = nc;
			break;
		case MG_EV_WS_MSG: {
			struct mg_ws_message *m = (struct mg_ws_message *) p;
			// Renterend either sends a button press as a u8 number or a json-string
			// which always begins with '{'
			printf("received message: %s\n", (char *)m->data.buf);
			if(((char *)m->data.buf)[0] == '{')
				json_load((char *)m->data.buf);
			else
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
	while (running) mg_mgr_poll(&mgr, 20);
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
	char *json = file_read(JSON_PATH);
	json_load(json);
	free(json);
	matchday_init();

	printf("Server loaded!\n");

	while (running) {
		char c = getchar();
		switch (c) {
			case DEAL_YELLOW_CARD:{
				if(md.cur.gameindex == md.games_count)
					break;
				WidgetCard wy = WidgetCard_create(add_card(YELLOW));
				send_widget(&wy, sizeof(WidgetCard));
				break;
			}
			case DEAL_RED_CARD: {
				if(md.cur.gameindex == md.games_count)
					break;
				WidgetCard wr = WidgetCard_create(add_card(RED));
				send_widget(&wr, sizeof(WidgetCard));
				break;
			}
			case DELETE_CARD: {
				if(md.cur.gameindex == md.games_count)
					break;
				u32 cur_i = md.cur.gameindex;
				if(md.games[cur_i].cards_count == 0){
					printf("No Cards to delete!\n");
					break;
				}
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
				u32 c = md.games[cur_i].cards_count+1;
				while(c > md.games[cur_i].cards_count || c <= 0)
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
				if(md.cur.gameindex == md.games_count)
					WidgetScoreboard_enabled = false;
				resend_widgets();
				break;
			/*
			case TOGGLE_WIDGET_HALFTIME:
				widget_halftime_enabled = !widget_halftime_enabled;
				send_widget_halftime(widget_halftime_create());
				break;
			*/
			case TOGGLE_WIDGET_LIVETABLE:
				WidgetLivetable_enabled = !WidgetLivetable_enabled;
				WidgetGameplan_enabled = false;
				WidgetGamestart_enabled = false;
				resend_widgets();
				break;
			case TOGGLE_WIDGET_GAMEPLAN:
				WidgetGameplan_enabled = !WidgetGameplan_enabled;
				WidgetGamestart_enabled = false;
				WidgetLivetable_enabled = false;
				resend_widgets();
				break;
			case TOGGLE_WIDGET_GAMESTART:
				WidgetGamestart_enabled = !WidgetGamestart_enabled;
				if(md.cur.gameindex == md.games_count)
					WidgetGamestart_enabled = false;
				else{
					WidgetLivetable_enabled = false;
					WidgetGameplan_enabled = false;
				}
				resend_widgets();
				break;
			case RELOAD_RENTNERJSON:
				if (c_rentner == NULL){
					fprintf(stderr, "ERROR: Rentnerend not connected, cant reload JSON!\n");
					break;
				}
				//We only send this signal to Rentnerend, there are no other, therefor we just use 0
				char w = 0;
				mg_ws_send(c_rentner, &w, sizeof(char), WEBSOCKET_OP_BINARY);
				break;
			case PRINT_HELP:
				printf(
					"======= Keyboard options =======\n"
					"y  yellow card\n"
					"r  red card\n"
					"d  delete card\n"
					"\n"
					"i  toggle scoreboard widget\n"
					"l  toggle livetable widget\n"
					"g  toggle gameplan widget\n"
					"s  toggle gamestart widget\n"
					"\n"
					"w  resend current widgets"
					"\n"
					"j  Reload rentnerend json\n"
					"?  print help\n"
					"q  quit\n"
					"================================\n"
				);
				break;
			case EXIT:
				running = false;
				break;
			case '\n': break;
			default:
				printf("Invalid input!\n");
		}
	}

	// WebSocket stuff, again
	if (pthread_join(thread, NULL) != 0)
		fprintf(stderr, "ERROR: Failed to join thread!\n");

cleanup:
	mg_mgr_free(&mgr);
	return 0;
}
