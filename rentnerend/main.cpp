#include <cstdint>
#include <QApplication>
#include <QFontDatabase>

#include "audio.hpp"
#include "constants.hpp"
#include "displaywindow.hpp"

int
main(int argc, char *argv[]) {
	QApplication app(argc, argv);

	audio::init();
	audio::play();

	// Changing font to "Kanit" globally
	const int32_t font_id = QFontDatabase::addApplicationFont(constants::FONT_FILE);
	const QStringList font_families = QFontDatabase::applicationFontFamilies(font_id);
	if (!font_families.isEmpty()) {
		const QFont app_font(font_families.at(0));
		QApplication::setFont(app_font);
	}

	// TODO PLAN
	// matchday
	// windows
	// websockets
	//inputwindow::InputWindow iw;     // constructor call
	displaywindow::DisplayWindow dw; // constructor call

	dw.widget.show();

	// TODO NOTES
	// windows
	// matchday
	//
	// ## 2
	// callbacks

	return app.exec();
}
