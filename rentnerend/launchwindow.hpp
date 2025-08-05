#pragma once

#include <QHBoxLayout>
#include <QLabel>
#include <QListWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QWidget>

namespace launchwindow {

struct LaunchWindow {
	QWidget window;
	QListWidget json_list;

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
	void add_json(const char *name, const char *addr);
};

} // namespace launchwindow
