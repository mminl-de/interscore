#pragma once

#include <QHBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QToolBar>
#include <QVBoxLayout>
#include <QWidget>

namespace launchwindow {

struct LaunchWindow {
	QWidget window;

	struct {
		QHBoxLayout main;
		QVBoxLayout buttons;
	} layouts;
	struct {
		QLabel title;
	} labels;
	struct {
		QPushButton new_json;
		QPushButton import_from_cycleballeu;
	} buttons;

	LaunchWindow();
};

} // namespace launchwindow
