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

// TODO MOVE
#define URL "ws://localhost:8081?client=rentner"
#define ORANGE "#c60"

struct DisplayWindow {
	QWidget widget;
	struct {
		struct {
			QLabel name;
			QLabel score;
		} t1;
		struct {
			QLabel name;
			QLabel score;
		} t2;
		QLabel time;
		QLabel colon;
	} labels;

	DisplayWindow();
	void update();
};

struct InputWindow {
	QWidget widget;
	struct {
		struct {
			QLabel name;
			QLabel score;
		} t1;
		struct {
			QLabel name;
			QLabel score;
		} t2;
		QLabel time;
		QLabel colon;
	} labels;
	struct {
		struct {
			QPushButton score_plus;
			QPushButton score_minus;
		} t1;
		struct {
			QPushButton score_plus;
			QPushButton score_minus;
		} t2;
		struct {
			QPushButton next;
			QPushButton prev;
			QPushButton switch_sides;
		} game;
		struct {
			QPushButton plus_1;
			QPushButton minus_1;
			QPushButton plus_20;
			QPushButton minus_20;
			QPushButton toggle_pause;
			QPushButton reset;
		} time;
		QPushButton connection;
	} buttons;
	QComboBox card_dealer;

	InputWindow();
	void update();
};

void update_input_window();
void update_display_window();
void websocket_send_card(CardType type, int player_index);
void websocket_send_button_signal(u8);
void screen_input_toggle_visibility(bool hide);
void ev_handler(struct mg_connection *c, int ev, void *p);

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

//fontsize is only used for icons atm, cry about it
QPushButton *
configure_button(
	QWidget *window,
	void (*callback_func)(),
	QStyle::StandardPixmap icon,
	int fontsize
) {
	QPushButton *result = new QPushButton("", window);
	QIcon i = QApplication::style()->standardIcon(icon);
	result->setIcon(i);
	result->setIconSize(QSize(fontsize, fontsize));
	QObject::connect(result, &QPushButton::clicked, callback_func);
	return result;
}

Matchday md;
struct mg_connection *server_con = NULL;
bool server_connected = false;
struct mg_mgr mgr;

QMediaPlayer player = QMediaPlayer();
QAudioOutput audio_output = QAudioOutput();

DisplayWindow wd; // constructor call
InputWindow wi;   // constructor call

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
void btn_cb_time_plus_20() {
	if (!md.cur.pause)
		return;
	md.cur.time += 20;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_PLUS_20);
}
void btn_cb_time_minus_20() {
	if (!md.cur.pause || md.cur.time < 20)
		return;
	md.cur.time -= 20;
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
	if(md.cur.pause) websocket_send_button_signal(TIME_TOGGLE_OFF);
	else websocket_send_button_signal(TIME_TOGGLE_ON);
}
void btn_cb_time_reset() {
	md.cur.time = md.deftime;
	md.cur.pause = true;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_RESET);
}

void btn_cb_red_card() {
	int player_index = wi.card_dealer.currentData().toInt();
	if (player_index == -1)
		return;
	add_card(RED, player_index);
	websocket_send_card(RED, player_index);
	wi.card_dealer.setCurrentIndex(0);
}

void btn_cb_yellow_card() {
	int player_index = wi.card_dealer.currentData().toInt();
	if (player_index == -1)
		return;
	add_card(YELLOW, player_index);
	websocket_send_card(YELLOW, player_index);
	wi.card_dealer.setCurrentIndex(0);
}

void btn_cb_connect() {
	mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
}

//extern "C" {

DisplayWindow::DisplayWindow() {
	this->widget.setWindowTitle("Interscore: Scoreboard Display");

	// Setting colors
	this->widget.setStyleSheet("background-color: black");
	this->labels.t1.name.setStyleSheet("font-size: 130px; color: white;");
	this->labels.t1.score.setStyleSheet("font-size: 600px; color:" ORANGE ";");
	this->labels.t2.name.setStyleSheet("font-size: 130px; color: white;");
	this->labels.t2.score.setStyleSheet("font-size: 600px; color:" ORANGE ";");
	this->labels.time.setStyleSheet("font-size: 500px; color: white;");
	this->labels.colon.setStyleSheet("font-size: 600px; color: white;");

	// Centering everything everywhere
	this->labels.t1.name.setAlignment(Qt::AlignCenter);
	this->labels.t1.score.setAlignment(Qt::AlignCenter);
	this->labels.t2.name.setAlignment(Qt::AlignCenter);
	this->labels.t2.score.setAlignment(Qt::AlignCenter);
	this->labels.time.setAlignment(Qt::AlignCenter);
	this->labels.colon.setAlignment(Qt::AlignCenter);

	// Filling in content
	this->labels.t1.name.setText("Team 1");
	this->labels.t1.score.setText("0");
	this->labels.t2.name.setText("Team 2");
	this->labels.t2.score.setText("0");
	this->labels.time.setText("0.00");
	this->labels.colon.setText(":");

	// Structuring
	QHBoxLayout *top_bar = new QHBoxLayout;
	top_bar->addWidget(&this->labels.t1.name);
	top_bar->addWidget(&this->labels.t2.name);

	QHBoxLayout *middle_bar = new QHBoxLayout;
	middle_bar->addWidget(&this->labels.t1.score, 3);
	middle_bar->addWidget(&this->labels.colon, 1);
	middle_bar->addWidget(&this->labels.t2.score, 3);

	QVBoxLayout *layout = new QVBoxLayout(&this->widget);
	layout->addLayout(top_bar, 1);
	layout->addLayout(middle_bar, 2);
	layout->addWidget(&this->labels.time, 2);

	this->update();
}

void
DisplayWindow::update() {
	// TODO
}


InputWindow::InputWindow() {
	// TODO WIP
	this->widget.setWindowTitle("Interscore: Scoreboard Input");

	// Setting colors
	this->labels.t1.name.setStyleSheet("font-size: 100px; color: black;");
	this->labels.t1.score.setStyleSheet("font-size: 400px; color:" ORANGE ";");
	this->labels.t2.name.setStyleSheet("font-size: 100px; color: black;");
	this->labels.t2.score.setStyleSheet("font-size: 400px; color:" ORANGE ";");
	this->labels.time.setStyleSheet("font-size: 300px; color: black;");
	this->labels.colon.setStyleSheet("font-size: 300px; color: black;");
	// TODO CONTINUE

	// Centering everything everywhere
	this->labels.t1.name.setAlignment(Qt::AlignCenter);
	this->labels.t1.score.setAlignment(Qt::AlignCenter);
	this->labels.t2.name.setAlignment(Qt::AlignCenter);
	this->labels.t2.score.setAlignment(Qt::AlignCenter);
	this->labels.time.setAlignment(Qt::AlignCenter);
	this->labels.colon.setAlignment(Qt::AlignCenter);

	// Filling in content
	this->labels.t1.name.setText("Team 1");
	this->labels.t1.score.setText("0");
	this->labels.t2.name.setText("Team 2");
	this->labels.t2.score.setText("0");
	this->labels.time.setText("0.00");
	this->labels.colon.setText(":");

	//configure_button(
	//	&this->buttons.t1.score_minus,
	//	this,
	//	btn_cb_t1_score_minus
	//)

	// Structuring
	QHBoxLayout *top_bar = new QHBoxLayout;
	top_bar->addWidget(&this->buttons.game.prev);
	top_bar->addWidget(&this->labels.t2.name);
	top_bar->addWidget(&this->buttons.game.switch_sides);
	top_bar->addWidget(&this->labels.t1.name);
	top_bar->addWidget(&this->buttons.game.next);

	QVBoxLayout *t2 = new QVBoxLayout;
	t2->addWidget(&this->buttons.t2.score_plus);
	t2->addWidget(&this->labels.t2.score);
	t2->addWidget(&this->buttons.t2.score_minus);

	QVBoxLayout *t1 = new QVBoxLayout;
	t1->addWidget(&this->buttons.t1.score_plus);
	t1->addWidget(&this->labels.t1.score);
	t1->addWidget(&this->buttons.t1.score_minus);

	QHBoxLayout *middle_bar = new QHBoxLayout;
	middle_bar->addLayout(t2, 3);
	middle_bar->addWidget(&this->labels.colon, 1);
	middle_bar->addLayout(t1, 3);

	QGridLayout *bottom_bar = new QGridLayout;
	bottom_bar->addWidget(&this->buttons.time.minus_20, 0, 0, 2, 1);
	bottom_bar->addWidget(&this->buttons.time.minus_1, 0, 1, 2, 1);
	bottom_bar->addWidget(&this->buttons.time.toggle_pause, 0, 2);
	bottom_bar->addWidget(&this->buttons.time.reset, 0, 3);
	bottom_bar->addWidget(&this->labels.time, 1, 2, 1, 2);
	bottom_bar->addWidget(&this->buttons.time.plus_1, 0, 4, 2, 1);
	bottom_bar->addWidget(&this->buttons.time.plus_20, 0, 5, 2, 1);

	QVBoxLayout *layout = new QVBoxLayout(&this->widget);
	layout->addLayout(top_bar, 1);
	layout->addLayout(middle_bar, 2);
	layout->addLayout(bottom_bar, 2);

	this->update();
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
	printf("sending json: %s\n", gettimems());
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, s, strlen(s)*sizeof(char), WEBSOCKET_OP_TEXT);
	printf("Finished sending json: %s\n", gettimems());
}

void ev_handler(struct mg_connection *c, int ev, void *p) {
	switch(ev) {
		case MG_EV_WS_OPEN: {
			printf("WebSocket conenction established!\n");
			server_con = c;
			server_connected = true;
			update_input_window();
			char* s = json_generate();
			websocket_send_json(s);
			free(s);
			break;
		}
		case MG_EV_WS_MSG: {
			struct mg_ws_message *wm = (struct mg_ws_message *) p;
			if ((int)wm->data.buf[0] == 0) {
				char* s = json_generate();
				websocket_send_json(s);
				free(s);
				printf("INFO: Sent the newest JSON version to backend\n");
			} else printf("WARNING: Received unknown signal from WebSocket Server!\n");
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
		wi.buttons.t1.score_plus.hide();
		wi.buttons.t1.score_minus.hide();
		wi.buttons.t2.score_plus.hide();
		wi.buttons.t2.score_minus.hide();
		// TODO
		//wi.buttons.cards.red->hide();
		//wi.buttons.cards.yellow->hide();
		//wi.buttons.game.next->hide();
		//wi.buttons.game.prev->hide();
		wi.buttons.game.switch_sides.hide();
		wi.buttons.time.plus_1.hide();
		wi.buttons.time.minus_1.hide();
		wi.buttons.time.plus_20.hide();
		wi.buttons.time.minus_20.hide();
		wi.buttons.time.reset.hide();
		wi.buttons.time.toggle_pause.hide();
		wi.labels.time.hide();
		wi.labels.t1.score.hide();
		//wi.labels.t1.name->hide();
		wi.labels.t2.score.hide();
		//wi.labels.t2.name->hide();
		wi.card_dealer.hide();
	} else {
		wi.buttons.t1.score_plus.show();
		wi.buttons.t1.score_minus.show();
		wi.buttons.t2.score_plus.show();
		wi.buttons.t2.score_minus.show();
		// TODO
		//wi.buttons.card.red->show();
		//wi.buttons.card.yellow->show();
		//wi.buttons.game.next->show();
		//wi.buttons.game.prev->show();
		wi.buttons.game.switch_sides.show();
		wi.buttons.time.plus_1.show();
		wi.buttons.time.minus_1.show();
		wi.buttons.time.plus_20.show();
		wi.buttons.time.minus_20.show();
		wi.buttons.time.reset.show();
		wi.buttons.time.toggle_pause.show();
		wi.labels.time.show();
		wi.labels.t1.score.show();
		//wi.labels.t1.name->show();
		wi.labels.t2.score.show();
		//wi.labels.t2.name->show();
		wi.card_dealer.show();
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

// alignment: 0:= left, 1:= center, 2:=right
// if fontsize is -1 use biggest fontsize possible
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
     	int w = wd.widget.width();
     	int h = wd.widget.height();

     	/*
     	if (md.cur.gameindex == md.games_count) {
     		update_label(wd.labels.t1.name, 0.06, 0.46, 0.01, 0.25, "ENDE", -1, true, Qt::AlignCenter, Qt::AlignTop);
     		update_label(wd.labels.t2.name, 0.06, 0.46, 0.01, 0.25, "ENDE", -1, true, Qt::AlignCenter, Qt::AlignTop);
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
     	update_label(wd.labels.t1.name, 0.02, 0.47, 0.01, 0.25, s, f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

     	update_label(wd.labels.colon, 0.47, 0.53, 0.01, 0.25, ":", f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

     	if (md.cur.halftime)
     		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
     	else
     		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
     	update_label(wd.labels.t2.name, 0.53, 0.98, 0.01, 0.25, s, f1.pointSize(), true, Qt::AlignHCenter, Qt::AlignTop);

     	//Display the Scores
     	if (md.cur.halftime)
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
     	else
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);

     	update_label(wd.labels.t1.score, 0, 0.5, 0.15, 0.65, s, -1, true, Qt::AlignCenter, Qt::AlignCenter);

     	if (md.cur.halftime)
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
     	else
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
     	update_label(wd.labels.t2.score, 0.5, 1, 0.15, 0.65, s, -1, true, Qt::AlignCenter, Qt::AlignCenter);

     	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
     	update_label(wd.labels.time, 0, 1, 0.5, 1, s, -1, true, Qt::AlignHCenter, Qt::AlignBottom);
     }

     void update_input_window() {
     	int w = wi.window->width();
     	int h = wi.window->height();

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
     	update_label(wi.labels.t1.name, 0.06, 0.46, 0.01, 0.25, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);

     	float height = (float)text_height(wi.labels.t1.name->text().toUtf8().constData(), wi.labels.t1.name->font())/h;

     	//Display prev game;
     	update_button(wi.buttons.game.prev, w, h, 0.01, 0.05, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

     	//Display switch sides;
     	update_button(wi.buttons.game.switch_sides, w, h, 0.47, 0.53, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

     	//Display next game;
     	update_button(wi.buttons.game.next, w, h, 0.95, 0.99, 0.01+(0.25-height)/2, 0.25-(0.25-height)/2);

     	//Display Team 2 Name
     	if (md.cur.halftime)
     		strcpy(s, md.teams[md.games[md.cur.gameindex].t1_index].name);
     	else
     		strcpy(s, md.teams[md.games[md.cur.gameindex].t2_index].name);
     	update_label(wi.labels.t2.name, 0.54, 0.94, 0.01, 0.25, s, fontsize, true, Qt::AlignCenter, Qt::AlignTop);


     	//Display the Scores
     	//Display Score Team 1
     	if (md.cur.halftime)
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
     	else
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
     	update_label(wi.labels.t1.score, 0, 0.5, 0.2, 0.5, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

     	//Display +- Score Team 1
     	float width;
     	width = (float)text_width(wi.labels.t1.score->text().toUtf8().constData(), wi.labels.t1.score->font())/w;
     	height = (float)text_height(wi.labels.t1.score->text().toUtf8().constData(), wi.labels.t1.score->font())/h;
     	update_button(wi.buttons.t1.score_plus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.21, 0.25);
     	update_button(wi.buttons.t1.score_minus, w, h, (0.5-width)/2, 0.5-(0.5-width)/2, 0.45, 0.49);

     	//Display Score Team 2
     	if (md.cur.halftime)
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t1);
     	else
     		sprintf(s, "%d", md.games[md.cur.gameindex].score.t2);
     	update_label(wi.labels.t2.score, 0.5, 1, 0.2, 0.5, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

     	//Display +- Score Team 2
     	width = (float)text_width(wi.labels.t2.score->text().toUtf8().constData(), wi.labels.t2.score->font())/w;
     	height = (float)text_height(wi.labels.t2.score->text().toUtf8().constData(), wi.labels.t2.score->font())/h;
     	update_button(wi.buttons.t2.score_plus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.21, 0.25);
     	update_button(wi.buttons.t2.score_minus, w, h, 0.5+(0.5-width)/2, 1-(0.5-width)/2, 0.45, 0.49);

     	//Display Time
     	sprintf(s, "%01d:%02d", md.cur.time/60, md.cur.time%60);
     	update_label(wi.labels.time, 0, 1, 0.5, 1, s, -1, true, Qt::AlignCenter, Qt::AlignBottom);

     	//Display +- Time
     	width = (float)text_width(wi.labels.time->text().toUtf8().constData(), wi.labels.time->font())/w;
     	height = (float)text_height(wi.labels.time->text().toUtf8().constData(), wi.labels.time->font())/h;
     	//update_button(&wi.buttons.t2.score_plus, wi.fixed, 0+(wi.width/2 - width)/2, wi.width/2-(wi.width/2 - width)/2, wi.height/5, wi.height/5 + ((wi.height/2+wi.height/8) - wi.height/5)-height);
     	update_button(wi.buttons.time.minus, w, h, 0.47-width/2, 0.5-width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
     	update_button(wi.buttons.time.plus, w, h, 0.5+width/2, 0.53+width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
     	update_button(wi.buttons.time.minus_20, w, h, 0.43-width/2, 0.46-width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);
     	update_button(wi.buttons.time.plus_20, w, h, 0.54+width/2, 0.57+width/2, 0.5+(0.5-height)/4, 1-(0.5-height)/2);

     	update_button(wi.buttons.time.toggle_pause, w, h, 0.51-width/2, 0.49, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);
     	update_button(wi.buttons.time.reset, w, h, 0.5, 0.49+width/2, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);

     	wi.card_dealer.clear();
     	u8 t1_index = md.games[md.cur.gameindex].t1_index;
     	u8 t2_index = md.games[md.cur.gameindex].t2_index;
     	wi.card_dealer.addItem("");
     	wi.card_dealer.addItem(md.players[md.teams[t1_index].keeper_index].name, QVariant(md.teams[t1_index].keeper_index));
     	wi.card_dealer.addItem(md.players[md.teams[t1_index].field_index].name, QVariant(md.teams[t1_index].field_index));
     	wi.card_dealer.addItem(md.players[md.teams[t2_index].keeper_index].name, QVariant(md.teams[t2_index].keeper_index));
     	wi.card_dealer.addItem(md.players[md.teams[t2_index].field_index].name, QVariant(md.teams[t2_index].field_index));
     	update_combobox(wi.card_dealer, w, h, 0.88, 0.98, 0.69, 0.73);
     	// TODO update_button(wi.buttons.card.yellow, w, h, 0.88, 0.925, 0.74, 0.79);
     	// TODO update_button(wi.buttons.card.red, w, h, 0.935, 0.98, 0.74, 0.79);

     	update_button(&wi.buttons.connection, w, h, 0.93, 0.99, 0.93, 0.99);
     	if (server_con == NULL) {
     		wi.buttons.connection.setEnabled(true);
     		QIcon icon = QApplication::style()->standardIcon(QStyle::SP_MessageBoxWarning);
     		wi.buttons.connection.setIcon(icon);
     	} else {
     		wi.buttons.connection.setEnabled(false);
     		QIcon icon = QApplication::style()->standardIcon(QStyle::SP_DialogApplyButton);
     		wi.buttons.connection.setIcon(icon);
     	}
     }


 Function to create the display window
      void create_input_window() {
      	wi.w = new QWidget;
      	wi.w->setWindowTitle("Scoreboard Input");

      	wi.labels.t1.name = new QLabel("", wi.widget);
      	wi.labels.t2.name = new QLabel("", wi.widget);
      	wi.labels.t1.score = new QLabel("", wi.widget);
      	wi.labels.t2.score = new QLabel("", wi.widget);
      	wi.labels.time = new QLabel("", wi.widget);
      	//Create Buttons
      	wi.buttons.t1.score_minus = configure_button(&wi.widget, btn_cb_t1_score_minus, QStyle::SP_ArrowDown, 32);
      	wi.buttons.t1.score_plus = configure_button(&wi.widget, btn_cb_t1_score_plus, QStyle::SP_ArrowUp, 32);
      	wi.buttons.t2.score_minus = configure_button(&wi.widget, btn_cb_t2_score_minus, QStyle::SP_ArrowDown, 32);
      	wi.buttons.t2.score_plus = configure_button(&wi.widget, btn_cb_t2_score_plus, QStyle::SP_ArrowUp, 32);

      	wi.buttons.game.next = configure_button(&wi.widget, btn_cb_game_next, QStyle::SP_ArrowForward, 32);

      	wi.buttons.game.prev = configure_button(&wi.widget, btn_cb_game_prev, QStyle::SP_ArrowBack, 32);
      	wi.buttons.game.switch_sides = configure_button(&wi.widget, btn_cb_game_switch_sides, QStyle::SP_BrowserReload, 32);
      	wi.buttons.time.plus_1 = configure_button(&wi.widget, btn_cb_time_plus, QStyle::SP_ArrowUp, 25);
      	wi.buttons.time.minus_1 = configure_button(&wi.widget, btn_cb_time_minus, QStyle::SP_ArrowDown, 25);
      	wi.buttons.time.plus_20 = configure_button(&wi.widget, btn_cb_time_plus_20, QStyle::SP_ArrowUp, 40);
      	wi.buttons.time.minus_20 = configure_button(&wi.widget, btn_cb_time_minus_20, QStyle::SP_ArrowDown, 40);
      	wi.buttons.time.toggle_pause = configure_button(&wi.widget, btn_cb_time_toggle_pause, QStyle::SP_MediaPause, 32);
      	wi.buttons.time.reset = configure_button(&wi.widget, btn_cb_time_reset, QStyle::SP_BrowserReload, 32);

      	// TODO
      	//wi.buttons.card.red = configure_button(&wi.widget, btn_cb_red_card, QStyle::SP_DialogApplyButton, 32);
      	//wi.buttons.card.yellow = configure_button(&wi.widget, btn_cb_yellow_card, QStyle::SP_DialogApplyButton, 32);
      	//wi.buttons.card.red->setStyleSheet("background-color: red;");
      	//wi.buttons.card.yellow->setStyleSheet("background-color: yellow;");

      	// TODO NOW
      	wi.card_dealer = QComboBox(&wi.widget);

      	wi.buttons.connection = configure_button(&wi.widget, btn_cb_connect, QStyle::SP_MessageBoxCritical, 50);

      	update_input_window();
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
			player.setPosition(0);
			player.play();
		}
		update_display_window();
		update_input_window();
	}
	if (md.cur.time == 0)
		md.cur.pause = true;
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

//} // extern "C"

int
main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	// Audio setup
	player.setAudioOutput(&audio_output);
	player.setSource(QUrl::fromLocalFile(SOUND_GAME_END));
	audio_output.setVolume(1);
	player.play(); // TODO DEBUG THEN REMOVE

	// Applying Kanit font globally
	const int32_t font_id = QFontDatabase::addApplicationFont("assets/ChivoMono-Regular.ttf");
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO REFACTOR
	char *json = common_read_file(JSON_PATH);
	json_load(json);
	free(json);

	// TODO REFACTOR
	matchday_init();

	mg_mgr_init(&mgr);
	mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
	QTimer *t1 = new QTimer(&wi.widget);
	QObject::connect(t1, &QTimer::timeout, &websocket_poll);
	t1->start(100);

	// TODO wd.widget.show();
	wi.widget.show();

	QShortcut *shortcut = new QShortcut(QKeySequence(Qt::Key_Space), &wi.widget);
	QObject::connect(shortcut, &QShortcut::activated, []() {printf("test\n"); btn_cb_time_toggle_pause();});

	QTimer *t2 = new QTimer(&wi.widget);
	QObject::connect(t2, &QTimer::timeout, &update_timer);
	t2->start(1000);

	QTimer *t3 = new QTimer(&wi.widget);
	QObject::connect(t3, &QTimer::timeout, &json_autosave);
	t3->start(2*60*1000);

	EventFilter event_filter;
	app.installEventFilter(&event_filter);

	const int stat = app.exec();
	// TODO FREE wi and wd keys
	return stat;
}
