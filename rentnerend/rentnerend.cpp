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
#include "../common.h"


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

#define URL "ws://localhost:8081?client=rentner"

void update_input_window();
void update_display_window();
void websocket_send_button_signal(u8);

Matchday md;
w_input wi;
w_display wd;
struct mg_connection *server_con = NULL;
bool server_connected = false;
struct mg_mgr mgr;

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
	if (md.cur.gameindex >= md.games_count-1)
		return;
	md.cur.gameindex++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(GAME_NEXT);
}
void btn_cb_game_prev() {
	if (md.cur.gameindex <= 0)
		return;
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
	if(!md.cur.pause)
		return;
	md.cur.time++;
	update_input_window();
	update_display_window();
	websocket_send_button_signal(TIME_PLUS);
}
void btn_cb_time_minus() {
	if(!md.cur.pause || md.cur.time <= 0)
		return;
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

void websocket_send_button_signal(u8 signal) {
	printf("sending signal\n");
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, &signal, sizeof(u8), WEBSOCKET_OP_BINARY);
}

void websocket_send_json(char *s) {
	if (!server_connected)
		printf("WARNING: Local Changes could not be send to Server, because the Server is not connected! This is very bad!\n");
	else
		mg_ws_send(server_con, &s, strlen(s)*sizeof(char), WEBSOCKET_OP_BINARY);
}

void ev_handler(struct mg_connection *c, int ev, void *p) {
	switch(ev) {
		case MG_EV_WS_OPEN:
			printf("WebSocket conenction established!\n");
			server_con = c;
			server_connected = true;
			//TODO FINAL hash von der JSON senden um sicher zu gehen, dass es die gleiche ist
			break;
		case MG_EV_WS_MSG: {
			struct mg_ws_message *wm = (struct mg_ws_message *) p;
			printf("Received WebSocket message: %.*s\n", (int)wm->data.len, wm->data.buf);
			break;
		}
		case MG_EV_ERROR:
			printf("WebSocket error: %s\n", (char *) p);
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

int text_width(const char *text, QFont font){
		QSize text_size = QFontMetrics(font).size(Qt::TextSingleLine, text);
		return text_size.width();
}

int text_height(const char *text, QFont font){
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

	// TODO TEST
	l->setText(QString::fromUtf8(text));
}

//TODO REMOVE FUNCTION FOR b->setGeometry
void update_button(QPushButton *b, int w, int h, float x_start, float x_end, float y_start, float y_end) {
	b->move(w*x_start, h*y_start);
	b->resize(w*(x_end-x_start), h*(y_end-y_start));
}

void update_display_window() {
	int w = wd.w->width();
	int h = wd.w->height();

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

	update_button(wi.b.time.toggle_pause, w, h, 0.51-width/2, 0.49, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);
	update_button(wi.b.time.reset, w, h, 0.5, 0.49+width/2, 0.5+(0.5-height)/4, 0.5+(0.5-height)/2);
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
	wi.b.time.plus = button_new(wi.w, btn_cb_time_plus, QStyle::SP_ArrowUp, 32);
	wi.b.time.minus = button_new(wi.w, btn_cb_time_minus, QStyle::SP_ArrowDown, 32);
	wi.b.time.toggle_pause = button_new(wi.w, btn_cb_time_toggle_pause, QStyle::SP_MediaPause, 32);
	wi.b.time.reset = button_new(wi.w, btn_cb_time_reset, QStyle::SP_BrowserReload, 32);

	update_input_window();
}

// Function to create the display window
void create_display_window() {
	wd.w = new QWidget;
	wd.w->setWindowTitle("Scoreboard Display");

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
	/*
	if (!server_connected){
		srand(time(nullptr));
		mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
	}
	else
	*/
		mg_mgr_poll(&mgr, 0);
		printf("test\n");
}

int main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	char *json = file_read(JSON_PATH);
	json_load(json);
	free(json);
	matchday_init();

    create_display_window();
    create_input_window();

	mg_log_set(MG_LL_DEBUG);
	mg_mgr_init(&mgr);
	mg_ws_connect(&mgr, URL, ev_handler, NULL, NULL);
	QTimer *t1 = new QTimer(wi.w);
	QObject::connect(t1, &QTimer::timeout, &websocket_poll);
	t1->start(1000);

	wd.w->show();
    wi.w->show();

	QTimer *t2 = new QTimer(wi.w);
	QObject::connect(t2, &QTimer::timeout, &update_timer);
	t2->start(1000);

	EventFilter *event_filter = new EventFilter;
	app.installEventFilter(event_filter);
	return app.exec();
}
