#include <QApplication>
#include <QWidget>
#include <QPushButton>
#include <QComboBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QIcon>
#include <QTimer>

#include <json-c/json.h>
#include <json-c/json_object.h>
#include "../mongoose/mongoose.h"

#include "../config.h"
#include "qnamespace.h"

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

typedef struct {
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
	if(!md.cur.halftime){
		md.games[md.cur.gameindex].score.t1++;
		websocket_send_button_signal(T1_SCORE_PLUS);
	} else {
		md.games[md.cur.gameindex].score.t2++;
		websocket_send_button_signal(T2_SCORE_PLUS);
	}
	update_input_window();
	update_display_window();
}
void btn_cb_t1_score_minus() {
	if(!md.cur.halftime){
		if (md.games[md.cur.gameindex].score.t1 > 0)
			md.games[md.cur.gameindex].score.t1--;
		websocket_send_button_signal(T1_SCORE_MINUS);
	} else {
		if (md.games[md.cur.gameindex].score.t2 > 0)
			md.games[md.cur.gameindex].score.t2--;
		websocket_send_button_signal(T2_SCORE_MINUS);
	}
	update_input_window();
	update_display_window();
}
void btn_cb_t2_score_plus() {
	if(!md.cur.halftime){
		md.games[md.cur.gameindex].score.t2++;
		websocket_send_button_signal(T2_SCORE_PLUS);
	} else {
		md.games[md.cur.gameindex].score.t1++;
		websocket_send_button_signal(T1_SCORE_PLUS);
	}
	update_input_window();
	update_display_window();
}
void btn_cb_t2_score_minus() {
	if(!md.cur.halftime){
		if (md.games[md.cur.gameindex].score.t2 > 0)
			md.games[md.cur.gameindex].score.t2--;
		websocket_send_button_signal(T2_SCORE_MINUS);
	} else {
		if (md.games[md.cur.gameindex].score.t1 > 0)
			md.games[md.cur.gameindex].score.t1--;
		websocket_send_button_signal(T1_SCORE_MINUS);
	}
	update_input_window();
	update_display_window();
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
	md.cur.pause = true;
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

QFont biggest_font_possible(const char *text, int max_width, int max_height, bool bold) {
    printf("big boys: text: %s, width: %d, height: %d\n", text, max_width, max_height);

    QFont font = QApplication::font();
    font.setBold(bold);

    int low = 1, high = 500;  // Reasonable font size range
    int bestSize = low;

    while (low <= high) {
        int mid = (low + high) / 2;
        font.setPointSize(mid);
		QSize text_size = QFontMetrics(font).size(Qt::TextSingleLine, text);
		//the rectangle calculates height way to conservative
		//textRect.setHeight(textRect.height() * 1.5);
		//textRect.setWidth(textRect.width() * 1.1);
		int width = text_size.width();
		int height = text_size.height();

        if (width <= max_width && height <= max_height) {
            bestSize = mid;  // Found a valid size, try bigger
            low = mid + 1;
        } else {
            high = mid - 1;  // Too big, try smaller
        }
		if(low > high)
			printf("w: %d/%d; h: %d/%d\n", width, max_width, height, max_height);
    }

    font.setPointSize(bestSize);
    printf("Final size: %d\n", bestSize);
    return font;
}

/*
QFont biggest_font_possible(const char *text, int max_width, int max_height, bool bold) {
	printf("big boys: text: %s, width: %d, height: %d\n", text, max_width, max_height);
	int fontsize = 1;
	QFont font = QApplication::font();
	font.setBold(bold);

    while (true) {
        font.setPointSize(fontsize);
		QSize text_size = QFontMetrics(font).size(Qt::TextSingleLine, text);
		//the rectangle calculates height way to conservative
		//textRect.setHeight(textRect.height() * 1.5);
		//textRect.setWidth(textRect.width() * 1.1);
		int width = text_size.width();
		int height = text_size.height();

        if (width > max_width || height > max_height) {
			printf("w: %d/%d; h: %d/%d\n", width, max_width, height, max_height);
            break;  // Stop if text is too large
        }
        fontsize++;
    }
	fontsize--;

	printf("text: %s, width: %d, height: %d\n", text, max_width, max_height);
	return font;
}
*/


/*
//Gets the biggest font size possible for a markuped text of a label
//QFont biggest_font_possible(const char *text, int max_fontsize, int x, int y, bool bold) {
QFont biggest_font_possible(const char *text, int width, int height, bool bold) {
	printf("big boys: text: %s, width: %d, height: %d\n", text, width, height);
	int fontsize = 1;
	QFont font = QApplication::font();
	font.setBold(bold);

    while (true) {
        font.setPointSize(fontsize);
        QFontMetrics fm = QFontMetrics(font);
        QRect textRect = fm.boundingRect(text);
		//the rectangle calculates height way to conservative
		textRect.setHeight(textRect.height() * 1.5);
		textRect.setWidth(textRect.width() * 1.1);

        if (textRect.width() > width || textRect.height() > height) {
			printf("w: %d/%d; h: %d/%d\n", textRect.width(), width, textRect.height(), height);
            break;  // Stop if text is too large
        }
        fontsize++;
    }
	fontsize--;

	printf("text: %s, width: %d, height: %d\n", text, width, height);
	return font;
}
*/

//alignment: 0:= left, 1:= center, 2:=right
//if fontsize is -1 use biggest fontsize possible
void update_label(QLabel *l, float x_start, float x_end, float y_start, float y_end, const char *text, int fontsize, bool bold, Qt::Alignment x_alignment, Qt::Alignment y_alignment) {
	printf("called update_label\n");
	int w = l->parentWidget()->width();
	int h = l->parentWidget()->height();

	if (fontsize == -1) {
		printf("getting biggest font possible\n");
		l->setFont(biggest_font_possible(text, w*(x_end-x_start), h*(y_end-y_start), bold));
	} else {
		printf("making font with size %d\n", fontsize);
		QFont f = QApplication::font();
		f.setBold(bold);
		f.setPointSize(fontsize);
		l->setFont(f);
	}

	QRect box(x_start, y_start, x_end-x_start, y_end-y_start);
	//l->setGeometry(box);
	l->move(w*x_start, h*y_start);
	l->resize(w*(x_end - x_start), h*(y_end - y_start));
	//l->setAlignment(x_alignment | y_alignment);
	l->setAlignment(y_alignment);
	l->setAlignment(x_alignment);

	// TODO TEST
	l->setText(QString::fromUtf8(text));
}

//TODO REMOVE FUNCTION FOR b->setGeometry
void update_button(QPushButton *b, int w, int h, float x_start, float x_end, float y_start, float y_end) {
	printf("w: %d, h: %d\n", w, h);

	b->move(w*x_start, h*y_start);
	b->resize(w*(x_end-x_start), h*(y_end-y_start));
}

void update_display_window() {
	int w = wd.w->width();
	int h = wd.w->height();

	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);

	//QFont f1 = biggest_font_possible(teamname, 0.5 - 0.05, 0.15, true);
	QFont f1 = biggest_font_possible(teamname, w*0.45, h*0.24, true);
	printf("Got f1 font: %d\n", f1.pointSize());
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);

	//QFont f2 = biggest_font_possible(teamname, 0.5 - 0.05, 0.15, true);
	QFont f2 = biggest_font_possible(teamname, w*0.45, h*0.24, true);
	printf("Got f2 font: %d\n", f2.pointSize());
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;

	char s[TEAMS_NAME_MAX_LEN];
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(wd.l.t1.name, 0.02, 0.47, 0.01, 0.25, s, f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

	update_label(wd.l.colon, 0.47, 0.53, 0.01, 0.25, ":", f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(wd.l.t2.name, 0.53, 0.98, 0.01, 0.25, s, f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

	//Display the Scores
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);

	update_label(wd.l.t1.score, 0, 0.5, 0.15, 0.65, s, -1, true, Qt::AlignCenter, Qt::AlignCenter);

	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(wd.l.t2.score, 0.5, 1, 0.15, 0.65, s, -1, true, Qt::AlignCenter, Qt::AlignCenter);

	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(wd.l.time, 0, 1, 0.5, 1, s, -1, true, Qt::AlignHCenter, Qt::AlignBottom);
}

void update_input_window() {
	int w = wi.w->width();
	int h = wi.w->height();

	//Display the Teamnames
	char teamname[TEAMS_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	QFont f1 = biggest_font_possible(teamname, w*0.4, h*0.24, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	QFont f2 = biggest_font_possible(teamname, w*0.4, h*0.24, true);
	printf("fontsize: %d, %d\n", f1.pointSize(), f2.pointSize());
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;
	int fontsize = f1.pointSize();
	char s[TEAMS_NAME_MAX_LEN];


	//Display Team 1 Name
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(wi.l.t1.name, 0.06, 0.46, 0.01, 0.25, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);

	//Display prev game;
	update_button(wi.b.game.prev, w, h, 0.01, 0.05, 0.01, 0.25);

	//Display switch sides;
	update_button(wi.b.game.switch_sides, w, h, 0.47, 0.53, 0.01, 0.25);

	//Display next game;
	update_button(wi.b.game.next, w, h, 0.95, 0.99, 0.01, 0.25);

	//Display Team 2 Name
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	update_label(wi.l.t2.name, 0.54, 0.94, 0.01, 0.25, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);


	//Display the Scores
	//Display Score Team 1
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	update_label(wi.l.t1.score, 0, 0.5, 0.2, 0.5, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Score Team 1
	float width, height;
	width = (float)wi.l.t1.score->width()/w;
	height = (float)wi.l.t1.score->height()/h;
	printf("width: %f: height: %f\n", width, height);
	//update_button(&wi.b.t1.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	//update_button(wi.b.t1.score_plus, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + 80);
	//update_button(wi.b.t1.score_minus, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/2 + wi.height/8 - 60, wi.height/2 + wi.height/8 + 20);
	update_button(wi.b.t1.score_plus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.22, 0.25);
	update_button(wi.b.t1.score_minus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.45, 0.48);

	//Display Score Team 2
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(wi.l.t2.score, 0.5, 1, 0.2, 0.5, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Score Team 2
	width = (float)wi.l.t2.score->width()/w;
	height = (float)wi.l.t2.score->height()/h;
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.t2.score_plus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.22, 0.25);
	update_button(wi.b.t2.score_minus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.45, 0.48);

	//Display Time
	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(wi.l.time, 0, 1, 0.5, 1, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Time
	width = wi.l.time->width();
	height = wi.l.time->height();
	width = 0.4;
	height= 0.2;
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.time.minus, w, h, 0.47-width/2, 0.5-width/2, 0.5+height/2, 1-height/2);
	update_button(wi.b.time.plus, w, h, 0.5+width/2, 0.53+width/2, 0.5+height/2, 1-height/2);

	update_button(wi.b.time.toggle_pause, w, h, 0.5-width/2, 0.49, 0.5+height/2, 1-(0.5-height)/2-height);
	update_button(wi.b.time.reset, w, h, 0.5, 0.5+width/2, 0.5+height/2, 1-(0.5-height)/2-height);
}

//fontsize is only used for icons atm, cry about it
QPushButton *button_new(QWidget *window, void (*callback_func)(), QStyle::StandardPixmap icon, int fontsize) {
	QPushButton *b = new QPushButton("", window);
	QIcon i = QApplication::style()->standardIcon(icon);
	b->setIcon(i);
	b->setIconSize(QSize(fontsize, fontsize));
	QObject::connect(b, &QPushButton::clicked, callback_func);
	return b;
}

// Function to create the display window
void create_input_window() {
	wi.w = new QWidget;
	wi.w->setWindowTitle("Scoreboard Input");

	//TODO FINAL This shit doesnt work, it still uses the old width and height when making the callback

	wi.l.t1.name = new QLabel("", wi.w);
	wi.l.t2.name = new QLabel("", wi.w);
	wi.l.t1.score = new QLabel("", wi.w);
	wi.l.t2.score = new QLabel("", wi.w);
	wi.l.time = new QLabel("", wi.w);
	//Create Buttons
	wi.b.t1.score_minus = button_new(wi.w, btn_cb_t1_score_minus, QStyle::SP_ArrowDown, 32);
	wi.b.t1.score_plus = button_new(wi.w, btn_cb_t1_score_plus, QStyle::SP_ArrowUp, 32);
	wi.b.t2.score_minus = button_new(wi.w, btn_cb_t2_score_minus, QStyle::SP_ArrowDown, 32);
	wi.b.t2.score_plus = button_new(wi.w, btn_cb_t2_score_plus, QStyle::SP_ArrowUp, 32);

	wi.b.game.next = button_new(wi.w, btn_cb_game_next, QStyle::SP_ArrowForward, 32);

	wi.b.game.prev = button_new(wi.w, btn_cb_game_prev, QStyle::SP_ArrowBack, 32);
	wi.b.game.switch_sides = button_new(wi.w, btn_cb_game_switch_sides, QStyle::SP_BrowserReload, 32);
	wi.b.time.plus = button_new(wi.w, btn_cb_time_plus, QStyle::SP_ArrowUp, 32);
	wi.b.time.minus = button_new(wi.w, btn_cb_time_minus, QStyle::SP_ArrowDown, 32);
	wi.b.time.toggle_pause = button_new(wi.w, btn_cb_time_toggle_pause, QStyle::SP_MediaPause, 32);
	wi.b.time.reset = button_new(wi.w, btn_cb_time_reset, QStyle::SP_BrowserReload, 32);
	/*
	wi.b.card.yellow = gtk_button_new_with_label("GELBE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.yellow, 0, 0);
	wi.b.card.red = gtk_button_new_with_label("ROTE KARTE");
	gtk_fixed_put(GTK_FIXED(wi.fixed), wi.b.card.red, 0, 0);
	*/

	printf("oiranset 2.\n");

	update_input_window();
}

// Function to create the display window
void create_display_window() {
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
	wd.l.colon = new QLabel("", wd.w);

	update_display_window();
}

class EventFilter : public QObject {
public:
	bool eventFilter(QObject *obj, QEvent *event) override {
		if (event->type() == QEvent::Resize) {
			printf("resized window\n");
			update_display_window();
			update_input_window();
		}
		return QObject::eventFilter(obj, event);
	}
};

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
    create_input_window();

	mg_mgr_init(&mgr);
	//QTimer *t1 = new QTimer(wi.w);
	//QObject::connect(t1, &QTimer::timeout, &websocket_poll);
	//t1->start(100);

	printf("aroistn\n");
	//wd.w->show();
    wi.w->show();

	QTimer *t2 = new QTimer(wi.w);
	QObject::connect(t2, &QTimer::timeout, &update_timer);
	t2->start(1000);

	mg_mgr_free(&mgr);

	EventFilter *event_filter = new EventFilter;
	app.installEventFilter(event_filter);
	return app.exec();
}
