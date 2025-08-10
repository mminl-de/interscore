#include <QApplication>
#include <QAudioOutput>
#include <QComboBox>
#include <QDebug>
#include <QFontDatabase>
#include <QHBoxLayout>
#include <QIcon>
#include <QLabel>
#include <QMediaPlayer>
#include <QPushButton>
#include <QTimer>
#include <QVBoxLayout>
#include <QWidget>
#include <QShortcut>

#include <json-c/json.h>
#include <json-c/json_object.h>
#include "../mongoose/mongoose.h"

#include "../config.h"
#include "qaudiooutput.h"
#include "qnamespace.h"
#include "../common.h"

#define TIME_UPDATE_INTERVAL_MS 1000

extern "C" {

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
			QPushButton *plus20;
			QPushButton *minus20;
			QPushButton *toggle_pause;
			QPushButton *reset;
		} time;
		QPushButton *connect;
	} b;
	QComboBox *dd_card_players;
} w_input;

#define URL "ws://localhost:8081?client=rentner"

void update_input_window();
void update_display_window();
void websocket_send_card(CardType type, int player_index);
void websocket_send_button_signal(u8);
void screen_input_toggle_visibility(bool hide);
void ev_handler(struct mg_connection *c, int ev, void *p);

Matchday md;
w_input wi;
w_display wd;
struct mg_connection *server_con = NULL;
bool server_connected = false;
struct mg_mgr mgr;
// TODO CHECK if you can allocate in the stack
QMediaPlayer *player = new QMediaPlayer;
QAudioOutput *audio_output = new QAudioOutput;

bool ws_send(struct mg_connection *con, char *message, int len, int op) {
	if (con == NULL) {
		printf("WARNING: client is not connected, couldnt send Message: '%*s'\n", len, message);
		return false;
	}
	return mg_ws_send(con, message, len, op) == len;
}

void btn_cb_t1_score_plus() {
	if (!md.cur.halftime) {
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
	if (!md.cur.halftime) {
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
	if (!md.cur.halftime) {
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
	if (!md.cur.halftime) {
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
	if (md.cur.gameindex >= md.games_count)
		return;
	md.cur.gameindex++;
	if (md.cur.gameindex == md.games_count)
		screen_input_toggle_visibility(true);
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_NEXT);
}
void btn_cb_game_prev() {
	if (md.cur.gameindex <= 0)
		return;
	md.cur.gameindex--;
	if (md.cur.gameindex == md.games_count-1)
		screen_input_toggle_visibility(false);
	else // TODO does this work?
		websocket_send_button_signal(GAME_PREV);
	update_input_window();
	update_display_window();
}
void btn_cb_game_switch_sides() {
	md.cur.halftime = !md.cur.halftime;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_SWITCH_SIDES);
}
void btn_cb_time_plus() {
	if (!md.cur.pause)
		return;
	md.cur.time++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_PLUS_1);
}
void btn_cb_time_minus() {
	if (!md.cur.pause || md.cur.time <= 0)
		return;
	md.cur.time--;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_MINUS_1);
}
void btn_cb_time_plus20() {
	if (!md.cur.pause)
		return;
	md.cur.time += 20;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_PLUS_20);
}
void btn_cb_time_minus20() {
	if (!md.cur.pause)
		return;
	else if (md.cur.time < 20) md.cur.time = 0;
	else md.cur.time -= 20;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_MINUS_20);
}

void btn_cb_time_toggle_pause() {
	if (md.cur.time == 0)
		return;
	md.cur.pause = !md.cur.pause;
	update_input_window();
	update_display_window();
	if(md.cur.pause) {
		char str[3]; //0: TIME_TOGGLE_UNPAUSE, 1-2: u16 time where we pause
		str[0] = TIME_TOGGLE_PAUSE;
		*((u16 *)(str+1)) = md.cur.time;
		ws_send(server_con, str, sizeof(u8) + sizeof(u16), WEBSOCKET_OP_TEXT);
	} else
		websocket_send_button_signal(TIME_TOGGLE_UNPAUSE);
}
void btn_cb_time_reset() {
	md.cur.time = md.deftime;
	md.cur.pause = true;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_RESET);
	char str[3]; //0: TIME_TOGGLE_UNPAUSE, 1-2: u16 time where we pause
	str[0] = TIME_TOGGLE_PAUSE;
	*((u16 *)(str+1)) = md.cur.time;
	ws_send(server_con, str, sizeof(u8) + sizeof(u16), WEBSOCKET_OP_TEXT);
}

void btn_cb_red_card() {
	int player_index = wi.dd_card_players->currentData().toInt();
	if (player_index == -1)
		return;
	add_card(RED, player_index);
	websocket_send_card(RED, player_index);
	wi.dd_card_players->setCurrentIndex(0);
}

void btn_cb_yellow_card() {
	int player_index = wi.dd_card_players->currentData().toInt();
	if (player_index == -1)
		return;
	add_card(YELLOW, player_index);
	websocket_send_card(YELLOW, player_index);
	wi.dd_card_players->setCurrentIndex(0);
}

void btn_cb_connect() {
	mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
}

void websocket_send_card(CardType type, int player_index) {
	if (!server_connected) {
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
		return;
	}
	u8 s[2];
	s[0] = YELLOW_CARD + type;
	s[1] = player_index;
	mg_ws_send(server_con, s, sizeof(u8)+sizeof(u8), WEBSOCKET_OP_BINARY);
}

void websocket_send_button_signal(u8 signal) {
	printf("Sending btn press: %s\n", gettimems());
	printf("sending signal\n");
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, &signal, sizeof(u8), WEBSOCKET_OP_BINARY);
	printf("Finished sending btn press: %s\n", gettimems());
}

void websocket_send_json(const char *s) {
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, s, strlen(s), WEBSOCKET_OP_TEXT);
	printf("Finished sending json (len: %d): %s\n", strlen(s), s);
}

void ev_handler(struct mg_connection *c, int ev, void *p) {
	switch(ev) {
	case MG_EV_WS_OPEN: {
		printf("WebSocket conenction established!\n");
		server_con = c;
		server_connected = true;
		update_input_window();
		break;
	}
	case MG_EV_WS_MSG: {
		struct mg_ws_message *wm = (struct mg_ws_message *) p;
		char str[3];

		switch ((int)wm->data.buf[0]) {
		case PLS_SEND_JSON: {
			char* s = json_generate();
			websocket_send_json(s);
			printf("INFO: Sent the newest JSON version to backend\n");
			break;
		}
		case PLS_SEND_CUR_GAMEINDEX: {
			str[0] = DATA_GAMEINDEX;
			// We need the check, because the frontend does not count gameindex + 1 at the end
			str[1] = md.cur.gameindex == md.games_count ? md.cur.gameindex-1 : md.cur.gameindex;
			ws_send(server_con, str, sizeof(u8) * 2, WEBSOCKET_OP_TEXT);
			break;
		}
		case PLS_SEND_CUR_HALFTIME:
			str[0] = DATA_HALFTIME;
			str[1] = md.cur.halftime;
			ws_send(server_con, str, sizeof(u8) * 2, WEBSOCKET_OP_TEXT);
			break;
		case PLS_SEND_CUR_IS_PAUSE:
			str[0] = DATA_IS_PAUSE;
			str[1] = md.cur.pause;
			ws_send(server_con, str, sizeof(u8) * 2, WEBSOCKET_OP_TEXT);
			break;
		case PLS_SEND_CUR_TIME:
			str[0] = DATA_TIME;
			*((u16 *)(str+1)) = md.cur.time;
			ws_send(server_con, str, sizeof(u8) + sizeof(u16), WEBSOCKET_OP_TEXT);
			break;
		case PLS_SEND_GAMESCOUNT: {
			str[0] = DATA_GAMESCOUNT;
			str[1] = md.games_count;
			ws_send(server_con, str, sizeof(u8) * 2, WEBSOCKET_OP_TEXT);
			break;
		}
		default: {
			printf("WARNING: Received unknown signal from WebSocket Server!\n");
			break;
		}
		}
		break;
	}
	case MG_EV_ERROR:
		printf("WebSocket error: %s\n", (char *) p);
		break;
	case MG_EV_CLOSE:
		printf("WebSocket closed!\n");
		server_con = NULL;
		server_connected = false;
		update_input_window();
		break;
	// signals that are not important
	case MG_EV_OPEN:
		break;
	}
}

void screen_input_toggle_visibility(bool hide) {
	if (hide) {
		wi.b.t1.score_plus->hide();
		wi.b.t1.score_minus->hide();
		wi.b.t2.score_plus->hide();
		wi.b.t2.score_minus->hide();
		wi.b.card.red->hide();
		wi.b.card.yellow->hide();
		//wi.b.game.next->hide();
		//wi.b.game.prev->hide();
		wi.b.game.switch_sides->hide();
		wi.b.time.plus->hide();
		wi.b.time.minus->hide();
		wi.b.time.plus20->hide();
		wi.b.time.minus20->hide();
		wi.b.time.reset->hide();
		wi.b.time.toggle_pause->hide();
		wi.l.time->hide();
		wi.l.t1.score->hide();
		//wi.l.t1.name->hide();
		wi.l.t2.score->hide();
		//wi.l.t2.name->hide();
		wi.dd_card_players->hide();
	} else {
		wi.b.t1.score_plus->show();
		wi.b.t1.score_minus->show();
		wi.b.t2.score_plus->show();
		wi.b.t2.score_minus->show();
		wi.b.card.red->show();
		wi.b.card.yellow->show();
		//wi.b.game.next->show();
		//wi.b.game.prev->show();
		wi.b.game.switch_sides->show();
		wi.b.time.plus->show();
		wi.b.time.minus->show();
		wi.b.time.plus20->show();
		wi.b.time.minus20->show();
		wi.b.time.reset->show();
		wi.b.time.toggle_pause->show();
		wi.l.time->show();
		wi.l.t1.score->show();
		//wi.l.t1.name->show();
		wi.l.t2.score->show();
		//wi.l.t2.name->show();
		wi.dd_card_players->show();
	}
}

int text_width(const char *text, QFont font) {
	QSize text_size = QFontMetrics(font).size(Qt::TextSingleLine, text);
	return text_size.width();
}

int text_height(const char *text, QFont font) {
	QSize text_size = QFontMetrics(font).size(Qt::TextSingleLine, text);
	return text_size.height()*0.6;
}

QFont biggest_font_possible(const char *text, int max_width, int max_height, bool bold) {
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
	}

	font.setPointSize(bestSize);
	return font;
}

//alignment: 0:= left, 1:= center, 2:=right
//if fontsize is -1 use biggest fontsize possible
void update_label(QLabel *l, float x_start, float x_end, float y_start, float y_end, const char *text, int fontsize, bool bold, Qt::Alignment x_alignment, Qt::Alignment y_alignment) {
	int w = l->parentWidget()->width();
	int h = l->parentWidget()->height();

	if (fontsize == -1) {
		l->setFont(biggest_font_possible(text, w*(x_end-x_start), h*(y_end-y_start), bold));
	} else {
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

	l->setText(QString::fromUtf8(text));
}

//TODO REMOVE FUNCTION FOR b->setGeometry
void update_button(QPushButton *b, int w, int h, float x_start, float x_end, float y_start, float y_end) {
	b->move(w*x_start, h*y_start);
	b->resize(w*(x_end-x_start), h*(y_end-y_start));
}

void update_combobox(QComboBox *b, int w, int h, float x_start, float x_end, float y_start, float y_end) {
	b->move(w*x_start, h*y_start);
	b->resize(w*(x_end-x_start), h*(y_end-y_start));
}

void update_display_window() {
	int w = wd.w->width();
	int h = wd.w->height();

	/*
	if (md.cur.gameindex == md.games_count) {
		update_label(wd.l.t1.name, 0.06, 0.46, 0.01, 0.25, "ENDE", -1, true, Qt::AlignCenter, Qt::AlignTop);
		update_label(wd.l.t2.name, 0.06, 0.46, 0.01, 0.25, "ENDE", -1, true, Qt::AlignCenter, Qt::AlignTop);
		return;
	}
	*/

	//Display the Teamnames
	char teamname[TEAM_NAME_MAX_LEN];
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);

	//QFont f1 = biggest_font_possible(teamname, 0.5 - 0.05, 0.15, true);
	QFont f1 = biggest_font_possible(teamname, w*0.45, h*0.24, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);

	//QFont f2 = biggest_font_possible(teamname, 0.5 - 0.05, 0.15, true);
	QFont f2 = biggest_font_possible(teamname, w*0.45, h*0.24, true);
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;

	char s[TEAM_NAME_MAX_LEN];
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
	char teamname[TEAM_NAME_MAX_LEN];

	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t1_index].name);
	QFont f1 = biggest_font_possible(teamname, w*0.4, h*0.24, true);
	strcpy(teamname, md.teams[md.games[md.cur.gameindex].t2_index].name);
	QFont f2 = biggest_font_possible(teamname, w*0.4, h*0.24, true);
	if (f2.pointSize() < f1.pointSize())
		f1 = f2;
	int fontsize = f1.pointSize();
	char s[TEAM_NAME_MAX_LEN];


	//Display Team 1 Name
	if (md.cur.halftime)
		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
	else
		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
	update_label(wi.l.t1.name, 0.06, 0.46, 0.01, 0.25, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);

	float height = (float)text_height(wi.l.t1.name->text().toUtf8().constData(), wi.l.t1.name->font())/h;

	//Display prev game;
	update_button(wi.b.game.prev, w, h, 0.01, 0.05, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

	//Display switch sides;
	update_button(wi.b.game.switch_sides, w, h, 0.47, 0.53, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

	//Display next game;
	update_button(wi.b.game.next, w, h, 0.95, 0.99, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

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
	float width;
	width = (float)text_width(wi.l.t1.score->text().toUtf8().constData(), wi.l.t1.score->font())/w;
	height = (float)text_height(wi.l.t1.score->text().toUtf8().constData(), wi.l.t1.score->font())/h;
	update_button(wi.b.t1.score_plus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.21, 0.25);
	update_button(wi.b.t1.score_minus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.45, 0.49);

	//Display Score Team 2
	if (md.cur.halftime)
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
	else
		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
	update_label(wi.l.t2.score, 0.5, 1, 0.2, 0.5, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Score Team 2
	width = (float)text_width(wi.l.t2.score->text().toUtf8().constData(), wi.l.t2.score->font())/w;
	height = (float)text_height(wi.l.t2.score->text().toUtf8().constData(), wi.l.t2.score->font())/h;
	update_button(wi.b.t2.score_plus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.21, 0.25);
	update_button(wi.b.t2.score_minus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.45, 0.49);

	//Display Time
	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
	update_label(wi.l.time, 0, 1, 0.5, 1, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

	//Display +- Time
	width = (float)text_width(wi.l.time->text().toUtf8().constData(), wi.l.time->font())/w;
	height = (float)text_height(wi.l.time->text().toUtf8().constData(), wi.l.time->font())/h;
	//update_button(&wi.b.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
	update_button(wi.b.time.minus, w, h, 0.47-width/2, 0.5-width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
	update_button(wi.b.time.plus, w, h, 0.5+width/2, 0.53+width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
	update_button(wi.b.time.minus20, w, h, 0.43-width/2, 0.46-width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
	update_button(wi.b.time.plus20, w, h, 0.54+width/2, 0.57+width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);

	update_button(wi.b.time.toggle_pause, w, h, 0.51-width/2, 0.49, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);
	update_button(wi.b.time.reset, w, h, 0.5, 0.49+width/2, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);

	wi.dd_card_players->clear();
	u8 t1_index = md.games[md.cur.gameindex].t1_index;
	u8 t2_index = md.games[md.cur.gameindex].t2_index;
	wi.dd_card_players->addItem("");
	wi.dd_card_players->addItem(md.players[md.teams[t1_index].keeper_index].name, QVariant(md.teams[t1_index].keeper_index));
	wi.dd_card_players->addItem(md.players[md.teams[t1_index].field_index].name, QVariant(md.teams[t1_index].field_index));
	wi.dd_card_players->addItem(md.players[md.teams[t2_index].keeper_index].name, QVariant(md.teams[t2_index].keeper_index));
	wi.dd_card_players->addItem(md.players[md.teams[t2_index].field_index].name, QVariant(md.teams[t2_index].field_index));
	update_combobox(wi.dd_card_players, w, h, 0.88, 0.98, 0.69, 0.73);
	update_button(wi.b.card.yellow, w, h, 0.88, 0.925, 0.74, 0.79);
	update_button(wi.b.card.red, w, h, 0.935, 0.98, 0.74, 0.79);

	update_button(wi.b.connect, w, h, 0.93, 0.99, 0.93, 0.99);
	if (server_con == NULL) {
		wi.b.connect->setEnabled(true);
		QIcon icon = QApplication::style()->standardIcon(QStyle::SP_MessageBoxWarning);
		wi.b.connect->setIcon(icon);
	} else {
		wi.b.connect->setEnabled(false);
		QIcon icon = QApplication::style()->standardIcon(QStyle::SP_DialogApplyButton);
		wi.b.connect->setIcon(icon);
	}
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
	wi.b.time.plus = button_new(wi.w, btn_cb_time_plus, QStyle::SP_ArrowUp, 25);
	wi.b.time.minus = button_new(wi.w, btn_cb_time_minus, QStyle::SP_ArrowDown, 25);
	wi.b.time.plus20 = button_new(wi.w, btn_cb_time_plus20, QStyle::SP_ArrowUp, 40);
	wi.b.time.minus20 = button_new(wi.w, btn_cb_time_minus20, QStyle::SP_ArrowDown, 40);
	wi.b.time.toggle_pause = button_new(wi.w, btn_cb_time_toggle_pause, QStyle::SP_MediaPause, 32);
	wi.b.time.reset = button_new(wi.w, btn_cb_time_reset, QStyle::SP_BrowserReload, 32);

	wi.b.card.red = button_new(wi.w, btn_cb_red_card, QStyle::SP_DialogApplyButton, 32);
	wi.b.card.yellow = button_new(wi.w, btn_cb_yellow_card, QStyle::SP_DialogApplyButton, 32);
	wi.b.card.red->setStyleSheet("background-color: red;");
	wi.b.card.yellow->setStyleSheet("background-color: yellow;");

	wi.dd_card_players = new QComboBox(wi.w);

	wi.b.connect = button_new(wi.w, btn_cb_connect, QStyle::SP_MessageBoxCritical, 50);

	update_input_window();
}

// Function to create the display window
void create_display_window() {
	wd.w = new QWidget;
	wd.w->setWindowTitle("Scoreboard Display");

	// Setting background color to black
	QPalette palette = wd.w->palette();
	palette.setColor(QPalette::Window, Qt::black);
	wd.w->setAutoFillBackground(true);
	wd.w->setPalette(palette);

	wd.l.t1.name = new QLabel("", wd.w);
	wd.l.t2.name = new QLabel("", wd.w);
	wd.l.t1.score = new QLabel("", wd.w);
	wd.l.t2.score = new QLabel("", wd.w);
	wd.l.time = new QLabel("", wd.w);
	wd.l.colon = new QLabel("", wd.w);

	// Setting label colors to orange for score and white for the rest
	wd.l.t1.name->setStyleSheet("color: white;");
	wd.l.t2.name->setStyleSheet("color: white;");
	wd.l.t1.score->setStyleSheet("color: #cc6600;");
	wd.l.t2.score->setStyleSheet("color: #cc6600;");
	wd.l.time->setStyleSheet("color: white;");
	wd.l.colon->setStyleSheet("color: white;");

	update_display_window();
}

class EventFilter : public QObject {
public:
	bool eventFilter(QObject *obj, QEvent *event) override {
		if (event->type() == QEvent::Resize) {
			update_display_window();
			update_input_window();
		}
		return QObject::eventFilter(obj, event);
	}
};

void update_timer() {
	if (!md.cur.pause && md.cur.time > 0) {
		md.cur.time--;
		//play sound if time is up
		if (md.cur.time == 0) {
			player->setPosition(0);
			player->play();
		}
		update_display_window();
		update_input_window();
	}
	if (md.cur.time == 0 && !md.cur.pause) {
		md.cur.pause = true;
		char str[3]; //0: TIME_TOGGLE_UNPAUSE, 1-2: u16 time where we pause
		str[0] = TIME_TOGGLE_PAUSE;
		*((u16 *)(str+1)) = md.cur.time;
		ws_send(server_con, str, sizeof(u8) + sizeof(u16), WEBSOCKET_OP_TEXT);
	}
}

void websocket_poll() {
	mg_mgr_poll(&mgr, 0);
}

void json_autosave() {
	//Save the old JSON file in case that something goes wrong
	if (rename(JSON_PATH, JSON_PATH_OLD) != 0) {
		printf("WARNING: Couldnt move %s to %s. Aborting autosaving the JSON\n", JSON_PATH, JSON_PATH_OLD);
		return;
	}
	char *s = json_generate();
	if (!file_write(JSON_PATH, s))
		printf("WARNING: Couldnt autosave JSON!\n");
	free(s);
	printf("INFO: Autosaved JSON successfully!\n");
}

int main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	//Set up the Audio Source for the player
	player->setAudioOutput(audio_output);
	audio_output->setVolume(1);
	player->setSource(QUrl::fromLocalFile(SOUND_GAME_END));

	// Applying Kanit font globally
	const int font_id = QFontDatabase::addApplicationFont("assets/ChivoMono-Regular.ttf");
	QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	char *json = common_read_file(JSON_PATH);
	json_load(json);
	free(json);
	matchday_init();

	create_display_window();
	create_input_window();

	mg_mgr_init(&mgr);
	mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
	QTimer *t1 = new QTimer(wi.w);
	QObject::connect(t1, &QTimer::timeout, &websocket_poll);
	t1->start(100);

	wd.w->show();
	wi.w->show();

	QShortcut *shortcut = new QShortcut(QKeySequence(Qt::Key_Space), wi.w);
	QObject::connect(shortcut, &QShortcut::activated, []() {printf("test\n"); btn_cb_time_toggle_pause();});

	QTimer *t2 = new QTimer(wi.w);
	QObject::connect(t2, &QTimer::timeout, &update_timer);
	t2->start(TIME_UPDATE_INTERVAL_MS);

	QTimer *t3 = new QTimer(wi.w);
	QObject::connect(t3, &QTimer::timeout, &json_autosave);
	t3->start(2*60*1000);

	EventFilter event_filter;
	app.installEventFilter(&event_filter);

	const int stat = app.exec();
	delete player;
	delete audio_output;
	delete wd.w;
	delete wi.w;
	return stat;
}

} // extern "C"
