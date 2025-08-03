#pragma once

#include <QLabel>
#include <QWidget>

namespace inputwindow {

struct InputWindow {
	QWidget window;

	struct {
		QLabel title;
	} start;

	InputWindow();
};

} // namespace inputwindow
