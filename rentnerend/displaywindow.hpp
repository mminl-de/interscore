#pragma once

#include <QLabel>
#include <QWidget>

namespace displaywindow {

struct DisplayWindow {
	QWidget window;
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
};

} // namespace displaywindow
