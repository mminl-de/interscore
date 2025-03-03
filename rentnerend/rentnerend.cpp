#include <QApplication>
#include <QWidget>
#include <QPushButton>
#include <QComboBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QIcon>
//#include <QTimer>

#include <json-c/json.h>
#include <json-c/json_object.h>
#include "../mongoose/mongoose.h"

#include "../config.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

typedef struct {
	int width;
	int height;
	QWidget *w;

	struct {
		struct {
			QLabel* name;
			QLabel* score;
		} t1;
		struct {
			QLabel* name;
			QLabel* score;
		} t2;
		QLabel* time;
		QLabel* colon;
	} l;
} w_display;

typedef struct {
	int width;
	int height;
	QWidget *w;
	struct {
		struct {
			QLabel* name;
			QLabel* score;
		} t1;
		struct {
			QLabel* name;
			QLabel* score;
		} t2;
		QLabel* time;
	} l;
	struct {
		struct {
			QPushButton *score_plus;
			QPushButton *score_minus;
		} t1;
		struct {
			QPushButton *score_plus;
			QPushButton *score_minus;
		} t2;
		struct {
			QPushButton *next;
			QPushButton *prev;
			QPushButton *switch_sides;
		} game;
		struct {
			QPushButton *yellow;
			QPushButton *red;
		} card;
		struct {
			QPushButton *plus;
			QPushButton *minus;
			QPushButton *toggle_pause;
			QPushButton *reset;
		} time;
	} b;
	QComboBox *dd_card_players;
} w_input;

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
		bool pause;
	} cur;
	Game *games;
	u8 games_count;
	Team *teams;
	u8 teams_count;
	Player *players;
	u8 players_count;
} Matchday;

enum {T1_SCORE_PLUS, T1_SCORE_MINUS, T2_SCORE_PLUS, T2_SCORE_MINUS, GAME_NEXT, GAME_PREV, GAME_SWITCH_SIDES, TIME_PLUS, TIME_MINUS, TIME_TOGGLE_PAUSE, TIME_RESET};

Matchday md;
w_input wi;
w_display wd;
struct mg_connection *server_con = NULL;
bool server_connected = false;
struct mg_mgr mgr;

void update_input_window();
void update_display_window();
void websocket_send_button_signal(int);

void btn_cb_t1_score_plus() {
	md.games[md.cur.gameindex].score.t1++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(T1_SCORE_PLUS);
}
void btn_cb_t1_score_minus() {
	if (md.games[md.cur.gameindex].score.t1 > 0)
		md.games[md.cur.gameindex].score.t1--;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(T1_SCORE_MINUS);
}
void btn_cb_t2_score_plus() {
	md.games[md.cur.gameindex].score.t2++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(T2_SCORE_PLUS);
}
void btn_cb_t2_score_minus() {
	if (md.games[md.cur.gameindex].score.t2 > 0)
		md.games[md.cur.gameindex].score.t2--;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(T2_SCORE_MINUS);
}
void btn_cb_game_next() {
	if (md.cur.gameindex < md.games_count-1)
		md.cur.gameindex++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_NEXT);
}
void btn_cb_game_prev() {
	if (md.cur.gameindex > 0)
		md.cur.gameindex--;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_PREV);
}
void btn_cb_game_switch_sides() {
	md.cur.halftime = !md.cur.halftime;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_SWITCH_SIDES);
}
void btn_cb_time_plus() {
	md.cur.time++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_PLUS);
}
void btn_cb_time_minus() {
	if (md.cur.time > 0)
		md.cur.time--;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_MINUS);
}
void btn_cb_time_toggle_pause() {
	md.cur.pause = !md.cur.pause;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_TOGGLE_PAUSE);
}
void btn_cb_time_reset() {
	md.cur.time = GAME_LENGTH;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_RESET);
}

void websocket_send_button_signal(int signal) {
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, &signal, sizeof(int), WEBSOCKET_OP_BINARY);
}

void ev_handler(struct mg_connection *c, int ev, void *p) {
	switch(ev) {
		case MG_EV_WS_OPEN:
			printf("WebSocket conenction established!\n");
			server_con = c;
			server_connected = true;
			//TODO FINAL hash von der JSON senden um sicher zu gehen, dass es die gleiche ist
			break;
		case MG_EV_CLOSE:
			printf("WebSocket closed!\n");
			server_con = NULL;
			server_connected = false;
			break;
		// signals that are not important
		case MG_EV_OPEN:
		break;
	}
}

//Set current_match to first match and 0-initialize every game
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

	char *filestring = (char *) malloc((file_size + 1) * sizeof(char));
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
	md.teams = (Team *) malloc(md.teams_count * sizeof(Team));

	md.players_count = md.teams_count*2;
	md.players = (Player *) malloc(md.players_count * sizeof(Player));

	// Read all the teams
	u32 i = 0;
	json_object_object_foreach(teams, teamname, teamdata) {
		md.teams[i].name = teamname;
		json_object *logo, *keeper, *field, *name, *color;

		json_object_object_get_ex(teamdata, "logo", &logo);
		md.teams[i].logo_filename = (char *) malloc(strlen(json_object_get_string(logo)) * sizeof(char));
		strcpy(md.teams[i].logo_filename, json_object_get_string(logo));

		json_object_object_get_ex(teamdata, "keeper", &keeper);
		json_object_object_get_ex(keeper, "name", &name);
		md.players[i*2].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2].name, json_object_get_string(name));
		md.players[i*2].team_index = i;
		md.players[i*2].role = 0;
		md.teams[i].keeper_index = i*2;


		json_object_object_get_ex(teamdata, "field", &field);
		json_object_object_get_ex(field, "name", &name);
		md.players[i*2+1].name = (char *) malloc(strlen(json_object_get_string(name)) * sizeof(char));
		strcpy(md.players[i*2+1].name, json_object_get_string(name));
		md.players[i*2+1].team_index = i;
		md.players[i*2+1].role = 1;
		md.teams[i].field_index = i*2+1;

		json_object_object_get_ex(teamdata, "color_light", &color);
		md.teams[i].color_light = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_light, json_object_get_string(color));

		json_object_object_get_ex(teamdata, "color_dark", &color);
		md.teams[i].color_dark = (char *) malloc(strlen(json_object_get_string(color)) *sizeof(char));
		strcpy(md.teams[i].color_dark, json_object_get_string(color));

		i++;
	}

	md.games_count = json_object_object_length(games);
	md.games = (Game *) malloc(md.games_count * sizeof(Game));

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
			md.games[i].cards = (Card *) malloc(md.games[i].cards_count * sizeof(Card));

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

//Gets the biggest font size possible for a markuped text of a label
//QFont biggest_font_possible(const char *text, int max_fontsize, int x, int y, bool bold) {
QFont biggest_font_possible(const char *text, int x, int y, bool bold) {
	printf("big boys: text: %s, x: %d, y: %d\n", text, x, y);
	//int width, height, fontsize = max_fontsize+1;
	int width, height, fontsize = y + 1;
	QFont font = QApplication::font();
	font.setBold(bold);

	do {
		font.setPointSize(fontsize--);

		QFontMetrics fm(font);
		width = fm.horizontalAdvance(text);
		height = fm.height();

		if (y == -1)
			y = height;
		if (x == -1)
			x = width;
	} while (fontsize > 1 && (width > x || height > y));
	printf("text: %s, width: %d, height: %d, x: %d, y: %d\n", text, width, height, x, y);
	return font;
}

//alignment: 0:= left, 1:= center, 2:=right
//if fontsize is -1 use biggest fontsize possible
void update_label(QLabel *l, int x_start, int x_end, int y_start, int y_end, const char *text, int fontsize, bool bold, Qt::Alignment x_alignment, Qt::Alignment y_alignment) {
	printf("Update Label Begin: text: %s\n", text);
	if (fontsize == -1) {
		printf("TODO calling bfp in update_label\n");
		l->setFont(biggest_font_possible(text, x_end-x_start, y_end-y_start, bold));
	} else {
		QFont f = QApplication::font();
		f.setBold(bold);
		f.setPointSize(fontsize);
	}

	QRect box(x_start, y_start, x_end-x_start, y_end-y_start);
	printf("box: %d-%d/%d-%d\n", x_start, x_end, y_start, y_end);
	//l->setGeometry(box);
	l->move(x_start, y_start);
	l->resize(x_end - x_start, y_end - y_start);
	//l->setAlignment(x_alignment | y_alignment);

	// TODO TEST
	l->setText(QString::fromUtf8(text));
}

//TODO REMOVE FUNCTION FOR b->setGeometry
void update_button(QPushButton *b, int x_start, int x_end, int y_start, int y_end) {
	b->move(x_start, y_start);
	b->resize(x_end-x_start, y_end-y_start);
}

void update_display_window() {
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	printf("calling bfp in update_display_window\n");
	QFont f1 = biggest_font_possible(teamname, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	printf("calling bfp in update_display_window again\n");
	QFont f2 = biggest_font_possible(teamname, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;

	char s[TEAMS_NAME_MAX_LEN];
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(wd.l.t1.name, wd.width/40, wd.width/40+(wd.width/2 - wd.width/20), 10, wd.height/6, s, f1.pointSize(), true, Qt::AlignCenter, Qt::AlignBottom);

	update_label(wd.l.colon, wd.width/40+(wd.width/2 - wd.width/20), wd.width/2 + wd.width/40, 0, wd.height/6, ":", f1.pointSize(), true, Qt::AlignCenter, Qt::AlignBottom);

	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(wd.l.t2.name, wd.width/2 + wd.width/40, wd.width - wd.width/40, 10, wd.height/6, s, f1.pointSize(), true, Qt::AlignCenter, Qt::AlignBottom);

	//Display the Scores
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(wd.l.t1.score, 0, wd.width/2, wd.height/5, wd.height/2, s, 350, true, Qt::AlignCenter, Qt::AlignVCenter);

	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(wd.l.t2.score, wd.width/2, wd.width-1, wd.height/6, wd.height/2, s, 350, true, Qt::AlignCenter, Qt::AlignVCenter);

	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(wd.l.time, 0, wd.width-1, wd.height/2, wd.height-1, s, 350, true, Qt::AlignCenter, Qt::AlignVCenter);
}

void update_input_window() {
	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	printf("calling bfp in update_input_window\n");
	QFont f1 = biggest_font_possible(teamname, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	printf("calling bfp in update_input_window again\n");
	QFont f2 = biggest_font_possible(teamname, wd.width/2 - wd.width/20, wd.height/6 - 10, true);
	printf("fontsize: %d, %d\n", f1.pointSize(), f2.pointSize());
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;
	int fontsize = f1.pointSize();
	char s[TEAMS_NAME_MAX_LEN];

	//Display prev game;
	update_button(wi.b.game.prev, wi.width/80, wi.width/20, 20, 20+f1.pointSize());

	//Display Team 1 Name
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(wi.l.t1.name, wi.width/20 + wi.width/40, wi.width/2 - (wi.width/30 + wi.width/40), 10, wi.height/6, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);

	//Display switch sides;
	update_button(wi.b.game.switch_sides, wi.width/2 - wi.width/30, wi.width/2 + wi.width/30, 20, 20+fontsize);

	//Display Team 2 Name
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(wi.l.t2.name, wi.width/2 + wi.width/30 + wi.width/40, wi.width - (wi.width/20 + wi.width/40), 10, wi.height/6, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);

	//Display next game;
	update_button(wi.b.game.next, wi.width - wi.width/20, wi.width - wi.width/80, 20, 20+fontsize);

	//Display the Scores
	//Display Score Team 1
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(wi.l.t1.score, 0, wi.width/2, wi.height/5, wi.height/2+wi.height/8, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Score Team 1
	int width, height;
	width = wi.l.t1.score->width();
	height = wi.l.t1.score->height();
	//update_button(&wi.b.t1.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.t1.score_plus, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + 80);
	update_button(wi.b.t1.score_minus, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/2 + wi.height/8 - 60, wi.height/2 + wi.height/8 + 20);

	//Display Score Team 2
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(wi.l.t2.score, wi.width/2, wi.width-1, wi.height/5, wi.height/2+wi.height/8, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Score Team 2
	width = wi.l.t2.score->width();
	height = wi.l.t2.score->height();
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.t2.score_plus, wi.width/2+(wi.width/2 - width)/2, wi.width - (wi.width/2 - width)/2, wi.height/5, wi.height/5 + 80);
	update_button(wi.b.t2.score_minus, wi.width/2+(wi.width/2 - width)/2, wi.width - (wi.width/2 - width)/2, wi.height/2 + wi.height/8 - 60, wi.height/2 + wi.height/8 + 20);

	//Display Time
	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(wi.l.time, 0, wi.width-1, wi.height/2+wi.height/5, wi.height-1, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Time
	width = wi.l.time->width();
	height = wi.l.time->height();
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.time.minus, wi.width/2 - width/2 - 160, wi.width/2 - width/2, wi.height/2+wi.height/5, wi.height-1);
	update_button(wi.b.time.plus, wi.width/2 + width/2, wi.width/2 + width/2 + 160, wi.height/2+wi.height/5, wi.height-1);

	update_button(wi.b.time.toggle_pause, wi.width/2 - width/2 + 10, wi.width/2-5, wi.height/2+wi.height/5, wi.height/2+wi.height/5+60);
	update_button(wi.b.time.reset, wi.width/2 + 5, wi.width/2 + width/2 - 10, wi.height/2+wi.height/5, wi.height/2+wi.height/5+60);
}

//fontsize is only used for icons atm, cry about it
void button_new(QPushButton **b, void (*callback_func)(), QStyle::StandardPixmap icon, int fontsize) {
	*b = new QPushButton();
	QIcon i = QApplication::style()->standardIcon(icon);
	(*b)->setIcon(i);
	(*b)->setIconSize(QSize(fontsize, fontsize));
	QObject::connect(*b, &QPushButton::clicked, callback_func);
}

// Function to create the display window
w_input create_input_window() {
	//wi.width = 1920;
	//wi.height = 1080;
	wi.width = 1280;
	wi.height = 720;
	wi.w = new QWidget;
	wi.w->setWindowTitle("Scoreboard Input");

	//TODO FINAL This shit doesnt work, it still uses the old width and height when making the callback

	wi.l.t1.name = new QLabel("", wi.w);
	wi.l.t2.name = new QLabel("", wi.w);
	wi.l.t1.score = new QLabel("", wi.w);
	wi.l.t2.score = new QLabel("", wi.w);
	wi.l.time = new QLabel("", wi.w);
	//Create Buttons
	button_new(&wi.b.t1.score_minus, btn_cb_t1_score_minus, QStyle::SP_ArrowDown, 32);
	button_new(&wi.b.t1.score_plus, btn_cb_t1_score_plus, QStyle::SP_ArrowUp, 32);
	button_new(&wi.b.t2.score_minus, btn_cb_t2_score_minus, QStyle::SP_ArrowDown, 32);
	button_new(&wi.b.t2.score_plus, btn_cb_t2_score_plus, QStyle::SP_ArrowUp, 32);

	button_new(&wi.b.game.next, btn_cb_game_next, QStyle::SP_ArrowForward, 32);

	button_new(&wi.b.game.prev, btn_cb_game_prev, QStyle::SP_ArrowBack, 32);
	button_new(&wi.b.game.switch_sides, btn_cb_game_switch_sides, QStyle::SP_DesktopIcon, 32);
	button_new(&wi.b.time.plus, btn_cb_time_plus, QStyle::SP_ArrowUp, 32);
	button_new(&wi.b.time.minus, btn_cb_time_minus, QStyle::SP_ArrowDown, 32);
	button_new(&wi.b.time.toggle_pause, btn_cb_time_toggle_pause, QStyle::SP_MediaPlay, 32);
	button_new(&wi.b.time.reset, btn_cb_time_reset, QStyle::SP_BrowserReload, 32);
	/*
	wi.b.card.yellow = gtk_button_new_with_label("GELBE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.yellow, 0, 0);
	wi.b.card.red = gtk_button_new_with_label("ROTE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.red, 0, 0);
	*/

	printf("oiranset 2.\n");

	update_input_window();

	// TODO BEGIN TEST
	QHBoxLayout *layout = new QHBoxLayout();
	layout->addWidget(wi.l.t1.name);
	wi.w->setLayout(layout);
	// TODO END TEST

    return wi;
}

// Function to create the display window
void create_display_window() {
	wd.width = 1920;
	wd.height = 1200;
	//wd.width = 1280;
	//wd.height = 720;
	wd.w = new QWidget;
	wd.w->setWindowTitle("Scoreboard Display");

	//TODO FINAL This shit doesnt work, it still uses the old width and height when making the callback
	//g_signal_connect(wd.w, "notify::width", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::height", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "notify::fullscreened", G_CALLBACK(update_display_window), NULL);
	//g_signal_connect(wd.w, "size-allocate", G_CALLBACK(update_display_window), NULL);

	wd.l.t1.name = new QLabel("", wd.w);
	wd.l.t2.name = new QLabel("", wd.w);
	wd.l.t1.score = new QLabel("", wd.w);
	wd.l.t2.score = new QLabel("", wd.w);
	wd.l.time = new QLabel("", wd.w);
	// TODO CONSIDER TEST
	wd.l.colon = new QLabel(":", wd.w);

	update_display_window();
}

void update_timer() {
	if (!md.cur.pause && md.cur.time > 0) {
		md.cur.time--;
		update_display_window();
		update_input_window();
	}
	if (md.cur.time == 0)
		md.cur.pause = true;
}

void websocket_poll() {
	if (!server_con)
		mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
	else
		mg_mgr_poll(&mgr, 0);
}

int main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	load_json(JSON_PATH);
	init_matchday();

    create_display_window();
    //wi = create_input_window();

	mg_mgr_init(&mgr);
	//QTimer *t1 = new QTimer(&wi.w);
	//QObject::connect(t1, &QTimer::timeout, &websocket_poll);
	//t1->start(100);

	printf("aroistn\n");
	wd.w->show();
    //wi.w->show();

	//QTimer *t2 = new QTimer(&wi.w);
	//QObject::connect(t2, &QTimer::timeout, &update_timer);
	//t2->start(1000);

	mg_mgr_free(&mgr);
	return app.exec();
}
