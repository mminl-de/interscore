#include <cstdio>

#include <QApplication>
#include <QComboBox>
#include <QFontDatabase>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>

#include "../common.h"

#define ORANGE "#c60"

extern "C" struct WindowDisplay {
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

WindowDisplay() {
	this->widget.setWindowTitle("Interscore: Scoreboard Display");

	// Setting colors
	this->labels.t1.name.setStyleSheet("color: white;");
	this->labels.t2.name.setStyleSheet("color: white;");
	this->labels.t1.score.setStyleSheet("color:" ORANGE ";");
	this->labels.t2.score.setStyleSheet("color:" ORANGE ";");
	this->labels.time.setStyleSheet("color: white;");
	this->labels.colon.setStyleSheet("color: white;");

	QHBoxLayout *top_bar = new QHBoxLayout(&this->widget);
	top_bar->addWidget(&this->labels.t1.name);
	top_bar->addWidget(&this->labels.t2.name);

	QHBoxLayout *middle_bar = new QHBoxLayout(&this->widget);
	middle_bar->addWidget(&this->labels.t1.score);
	middle_bar->addWidget(&this->labels.colon);
	middle_bar->addWidget(&this->labels.t2.score);

	QVBoxLayout *layout = new QVBoxLayout(&this->widget);
	layout->addLayout(top_bar);
	layout->addLayout(middle_bar);
	layout->addWidget(&this->labels.time);

	this->widget.setLayout(layout);
	// TODO NOW
	this->update();
}

void
update() {

}
};

extern "C" struct WindowInput {
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

WindowInput() {
	this->widget.setWindowTitle("Interscore: Scoreboard Input");
	// TODO WIP
	this->update();
}

void
update() {

}
};

struct EventFilter : public QObject {
	WindowDisplay *wd;
	WindowInput *wi;

EventFilter(WindowDisplay *wd, WindowInput *wi)
	: wd(wd), wi(wi) {}

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
Button_new(QWidget *window, void (*cb)(), QStyle::StandardPixmap icon, u16 fontsize) {
	QPushButton *result = new QPushButton("", window);

	QIcon qicon = QApplication::style()->standardIcon(icon);
	result->setIcon(qicon);
	result->setIconSize(QSize(fontsize, fontsize));

	QObject::connect(result, &QPushButton::clicked, cb);
	return result;
}

int
main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	// TODO ADD audio player setup

	// Applying custom font globally
	const i32 font_id = QFontDatabase::addApplicationFont("fonts/ChivoMono-Regular.ttf");
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO ADD read json
	// load json
	// free json
	// init matchday

	WindowDisplay wd;
	WindowInput wi;

	// Event filter for handling layout on window resize.
	EventFilter filter(&wd, &wi);
	app.installEventFilter(&filter);

	wd.widget.show();
	wi.widget.show();

	// TODO ADD connect mongoose

	// TODO bind space to pause time

	// TODO ADD timer_update
	// TODO ADD autosave

	return app.exec();
}
