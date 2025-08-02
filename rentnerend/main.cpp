#include <cstdlib> // TODO CONSIDER

#include <QApplication>
#include <QAudioOutput>
#include <QComboBox>
#include <QFontDatabase>
#include <QHBoxLayout>
#include <QLabel>
#include <QMediaPlayer>
#include <QPushButton>
#include <QVBoxLayout>

#include "../common/matchday.h"
#include "../common.h"
#include "../config.h"

#define ORANGE "#c60"

extern "C" {

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

void
InputWindow::update() {
	// TODO
}

struct EventFilter : public QObject {
	DisplayWindow *wd;
	InputWindow *wi;

	EventFilter(DisplayWindow *wd, InputWindow *wi) : wd(wd), wi(wi) {}

	bool
	eventFilter(QObject *obj, QEvent *event) override {
		if (event->type() == QEvent::Resize) {
			wd->update();
			wi->update();
		}
		return QObject::eventFilter(obj, event);
	}
};

QPushButton *
button_with_icon(QWidget *const window, void (*const cb)(), QStyle::StandardPixmap icon, u16 fontsize) {
	QPushButton *const result = new QPushButton("", window);

	QIcon qicon = QApplication::style()->standardIcon(icon);
	result->setIcon(qicon);
	result->setIconSize(QSize(fontsize, fontsize));

	QObject::connect(result, &QPushButton::clicked, cb);
	return result;
}

} // extern "C"

int
main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	// Audio setup
	QMediaPlayer player = QMediaPlayer();
	QAudioOutput audio_output = QAudioOutput();
	player.setAudioOutput(&audio_output);
	player.setSource(QUrl::fromLocalFile(RENTNEREND_SOUND));
	audio_output.setVolume(1);
	player.play(); // TODO DEBUG THEN REMOVE

	// Applying custom font globally
	const i32 font_id = QFontDatabase::addApplicationFont("fonts/Kanit-Regular.ttf");
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO ADD read json
	// load json
	// free json
	// init matchday
	const char *json = util_read_file(JSON_PATH);
	Matchday md = matchday_init(json); // TODO MEM free matchday later
	free(json);

	// Actual window creation
	DisplayWindow wd;	// constructor call
	InputWindow wi;		// constructor call

	// Event filter for handling layout on window resize.
	EventFilter filter(&wd, &wi);
	app.installEventFilter(&filter);

	//wd.widget.show();
	wi.widget.show();

	// TODO ADD connect mongoose

	// TODO bind space to pause time

	// TODO ADD timer_update
	// TODO ADD autosave

	return app.exec();
}
