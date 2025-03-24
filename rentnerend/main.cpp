#include <cstdio>

#include <QApplication>
#include <QFontDatabase>

#include "../common.h"

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
