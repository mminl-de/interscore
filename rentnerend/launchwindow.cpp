#include <QLabel>
#include <QListWidget>
#include <QPainter>
#include <QPushButton>
#include <QVBoxLayout>

#include "constants.hpp"
#include "launchwindow.hpp"

// Returns a heap-allocated instance of the JSON list for the launch window.
// The caller doesn't have to free the result if it's passed as a child to a
// Qt widget.
QListWidgetItem *json_list_item(const char *name, const char *address) {
	QListWidgetItem *const result = new QListWidgetItem;
	QWidget *const card = new QWidget;
	QVBoxLayout *const layout = new QVBoxLayout(card);

	QLabel *const big_label = new QLabel(name);
	QLabel *const smol_label = new QLabel(address);

	layout->addWidget(big_label);
	layout->addWidget(smol_label);
	card->setLayout(layout);

	result->setSizeHint(card->sizeHint());
	return result;
}

launchwindow::LaunchWindow::LaunchWindow() {
	this->window.setWindowTitle("Interscore v" constants__VERSION);
	this->window.setLayout(&this->layouts.main);

	// TODO NOW DEBUG
	// TODO TEST
	for (int i = 0; i < 10; ++i) {
		add_json("Gifhorn", "~/downloads/gifhorn.json");
	}

	this->layouts.main.addWidget(&this->json_list);
	this->layouts.main.addLayout(&this->layouts.buttons);

	this->layouts.buttons.addWidget(&this->buttons.new_json);
	this->layouts.buttons.addWidget(&this->buttons.import_from_cycleballeu);

	// TODO FINAL TRANSLATE
	this->labels.title.setText("Interscore");
	this->buttons.new_json.setText("Create new tournament");
	this->buttons.import_from_cycleballeu.setText("Import from cycleball.eu");
}

void
launchwindow::LaunchWindow::add_json(const char *name, const char *addr) {
	QListWidgetItem *const result = new QListWidgetItem;
	QWidget *const card = new QWidget;
	QVBoxLayout *const layout = new QVBoxLayout(card);

	QLabel *const big_label = new QLabel(name);
	QLabel *const smol_label = new QLabel(addr);

	layout->addWidget(big_label);
	layout->addWidget(smol_label);
	card->setLayout(layout);

	result->setSizeHint(card->sizeHint());
	this->json_list.addItem(result);
	this->json_list.setItemWidget(result, card);
}
