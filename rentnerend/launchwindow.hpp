#pragma once

#include <QHBoxLayout>
#include <QLabel>
#include <QListWidget>
#include <QPushButton>
#include <QSettings>
#include <QVBoxLayout>
#include <QWidget>

namespace launchwindow {

struct LaunchWindow {
	QSettings *settings;
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
		QPushButton import_json;
		QPushButton import_from_cycleballeu;
	} buttons;

	LaunchWindow(QSettings *const settings);

	// Add an entry describing a JSON file containing tournament data to the list
	// in the launch window.
	void add_json(const char *name, const char *addr);

	// Load the JSON list from disk.
	void load_list(void);

	// Save the name and address of a newly created tournament JSON to persistent
	// history.
	void save_to_history(const char *name, const char *addr);

	// Select the n-th element in the JSON list. Counting starts at zero.
	// Assumes it exists.
	void select_item(const uint16_t n);
};

} // namespace launchwindow
