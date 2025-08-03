#include <QLabel>
#include <QPushButton>
#include <QToolBar>
#include <QVBoxLayout>

#include "constants.hpp"
#include "launchwindow.hpp"

launchwindow::LaunchWindow::LaunchWindow() {
	this->window.setWindowTitle("Interscore v" CONSTANTS__VERSION);
	this->window.setLayout(&this->layouts.main);

	// TODO NOW
	auto *json_list = new QPushButton("list box TODO");

	this->layouts.main.addWidget(json_list);
	this->layouts.main.addLayout(&this->layouts.buttons);

	this->layouts.buttons.addWidget(&this->buttons.new_json);
	this->layouts.buttons.addWidget(&this->buttons.import_from_cycleballeu);

	// TODO FINAL TRANSLATE
	this->labels.title.setText("Interscore");
	this->buttons.new_json.setText("Create new tournament");
	this->buttons.import_from_cycleballeu.setText("Import from cycleball.eu");
}
