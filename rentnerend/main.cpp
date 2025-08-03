#include <cstdint>
#include <QApplication>
#include <QFontDatabase>
#include <QHBoxLayout>

#include "audio.hpp"
#include "constants.hpp"
#include "displaywindow.hpp"
#include "inputwindow.hpp"

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

	inputwindow::InputWindow iw; // constructor call
	iw.window.show();

	//displaywindow::DisplayWindow dw; // constructor call
	//dw.window.show();

	// TODO NOTES
	// windows
	// matchday
	//
	// ## 2
	// callbacks

	// TODO PLAN
	// websockets

	return app.exec();
}
