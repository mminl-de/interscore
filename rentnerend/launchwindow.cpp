#include <QLabel>
#include <QKeySequence>
#include <QListWidget>
#include <QObject>
#include <QPushButton>
#include <QSettings>
#include <QVBoxLayout>

#include "constants.hpp"
#include "launchwindow.hpp"

launchwindow::LaunchWindow::LaunchWindow(
	QSettings *settings,
	editorwindow::EditorWindow *ew
) {
	this->settings = settings;
	this->window.setWindowTitle("Interscore v" constants__VERSION);
	this->window.setLayout(&this->layouts.main);

	this->layouts.main.addLayout(&this->layouts.buttons);
	this->layouts.main.addWidget(&this->json_list);

	this->layouts.buttons.addWidget(&this->buttons.new_json);
	this->layouts.buttons.addWidget(&this->buttons.import_json);
	this->layouts.buttons.addWidget(&this->buttons.import_from_cycleballeu);

	// TODO FINAL TRANSLATE
	this->labels.title.setText("Interscore");
	this->buttons.new_json.setText("Create new tournament");
	this->buttons.import_json.setText("Import from file");
	this->buttons.import_from_cycleballeu.setText("Import from cycleball.eu");

	this->buttons.new_json.setShortcut(QKeySequence("Ctrl+N")); // TODO NOW

	QObject::connect(
		&this->buttons.new_json,
		&QPushButton::clicked,
		[ew]() { ew->dialog.show(); }
	);

	// TODO PLAN
	// loading list from datapath
	// reload_list function
	//     checks for every json list item, whether the file still exists
	//     if not, removes it from the list
	this->load_list();
}

void
launchwindow::LaunchWindow::add_json(const char *name, const char *addr) {
	QListWidgetItem *const item = new QListWidgetItem;
	QWidget *const card = new QWidget;
	QVBoxLayout *const layout = new QVBoxLayout(card);

	QLabel *const name_label = new QLabel(name);
	QLabel *const addr_label = new QLabel(addr);

	layout->addWidget(name_label);
	layout->addWidget(addr_label);
	card->setLayout(layout);

	item->setSizeHint(card->sizeHint());
	this->json_list.addItem(item);
	this->json_list.setItemWidget(item, card);
}

void
launchwindow::LaunchWindow::load_list(void) {
	const uint16_t size = this->settings->beginReadArray("json_list");
	for (int i = 0; i < size; ++i) {
		this->settings->setArrayIndex(i);
		const QString name = this->settings->value("name").toString();
		const QString addr = this->settings->value("addr").toString();
		this->add_json(name.toUtf8().constData(), addr.toUtf8().constData());
	}
	this->settings->endArray();

}

void
launchwindow::LaunchWindow::save_to_history(const char* name, const char *addr) {
	// TODO
}

void
launchwindow::LaunchWindow::select_item(const uint16_t n) {
	this->json_list.setCurrentRow(n);
	this->json_list.item(n)->setSelected(true);
	this->json_list.setFocus();
}
