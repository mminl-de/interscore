#include <cstdio>

#include <QApplication>
#include <QComboBox>
#include <QFontDatabase>
#include <QLabel>
#include <QPushButton>

#include "../common.h"

typedef struct {
	QWidget *widget;
	struct {
		struct {
			QLabel *name;
			QLabel *score;
		} t1;
		struct {
			QLabel *name;
			QLabel *score;
		} t2;
		QLabel *time;
	} labels;
} WindowDisplay;

typedef struct {
	QWidget *widget;
	struct {
		struct {
			QLabel *name;
			QLabel *score;
		} t1;
		struct {
			QLabel *name;
			QLabel *score;
		} t2;
		QLabel *time;
	} labels;
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
			QPushButton *plus_1;
			QPushButton *minus_1;
			QPushButton *plus_20;
			QPushButton *minus_20;
			QPushButton *toggle_pause;
			QPushButton *reset;
		} time;
		QPushButton *connection;
	} buttons;
	QComboBox *card_dealer;
} WindowInput;

int main(int argc, char *argv[]) {
	const QApplication app(argc, argv);

	// TODO ADD audio player setup

	// Applying custom font globally
	const i32 font_id = QFontDatabase::addApplicationFont("fonts/ChivoMono-Regular.ttf");
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO ADD read json

	// TODO ADD create both windows
	// and show them
	// maybe make an about window

	// TODO ADD connect mongoose

	// TODO bind space to pause time

	// TODO ADD timer_update
	// TODO ADD autosave

	return app.exec();
}
