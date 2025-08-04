#include <cstdint>
#include <QApplication>
#include <QFontDatabase>
#include <QHBoxLayout>

#include "audio.hpp"
#include "constants.hpp"
#include "displaywindow.hpp"
#include "launchwindow.hpp"

int
main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	audio::init();
	//audio::play(); // TODO

	// Changing font to "Kanit" globally
	const int32_t font_id = QFontDatabase::addApplicationFont(CONSTANTS__FONT_FILE);
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO PLAN
	// matchday

	launchwindow::LaunchWindow lw; // constructor call
	lw.window.show();

	//displaywindow::DisplayWindow dw; // constructor call
	//dw.window.show();

	// TODO NOTE actual screens
	// ## launch
	// absolute title
	// open old tournament
	// create new tournament
	// about us
	// set language
	//
	// ## actual
	// change tournament
	// about us
	// set language

	// TODO NOTE things on the start screen
	// title and version
	// about button
	// settings
	//     set language
	// load json or create new one
	// ## json
	// event name
	// number of groups
	// role list
	// player list
	// game list

	// TODO PLAN
	// websockets

	return app.exec();
}
