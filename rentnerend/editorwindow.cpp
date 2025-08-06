#include <cstdio> // TODO NOW
#include <QDialogButtonBox>
#include <QObject>
#include <QPushButton>

#include "editorwindow.hpp"

editorwindow::EditorWindow::EditorWindow(void) {
	// TODO TRANSLATE
	this->dialog.setWindowTitle("Create new tournament");
	this->dialog.setLayout(&this->layouts.main);

	this->dialog_buttons.setStandardButtons(
		QDialogButtonBox::Ok |
		QDialogButtonBox::Apply |
		QDialogButtonBox::Cancel
	);

	this->layouts.json_address.addWidget(&this->json_address);
	this->layouts.json_address.addWidget(&this->buttons.json_address);

	this->layouts.main.addWidget(&this->labels.tournament_name);
	this->layouts.main.addWidget(&this->tournament_name);
	this->layouts.main.addWidget(&this->labels.json_address);
	this->layouts.main.addLayout(&this->layouts.json_address);
	this->layouts.main.addWidget(&this->labels.role_list);
	this->layouts.main.addWidget(&this->role_list);
	this->layouts.main.addWidget(&this->dialog_buttons);

	this->labels.tournament_name.setText("Tournament name"); // TODO TRANSLATE
	this->labels.tournament_name.setBuddy(&this->tournament_name);

	this->labels.json_address.setText("Path to store tournament in"); // TODO TRANSLATE
	this->labels.json_address.setBuddy(&this->json_address);
	this->buttons.json_address.setText("Browse"); // TODO TRANSLATE

	this->labels.role_list.setText("Player roles"); // TODO TRANSLATE

	QPushButton *save_and_return = this->dialog_buttons.button(QDialogButtonBox::Ok);
	QPushButton *save_and_start = this->dialog_buttons.button(QDialogButtonBox::Apply);
	QPushButton *abort = this->dialog_buttons.button(QDialogButtonBox::Cancel);
	save_and_return->setText("Save and Return"); // TODO TRANSLATE
	QObject::connect(
		save_and_return,
		&QPushButton::clicked,
		[this]() {
			printf("save and return\n");
			//this->dialog.hide();
		}
	);
	// TODO DEBUG why does this button require two tabs to cycle through?
	save_and_start->setText("Save and Start"); // TODO TRANSLATE
	QObject::connect(
		save_and_start,
		&QPushButton::clicked,
		[]() {
			// TODO
		}
	);
	abort->setText("Abort"); // TODO TRANSLATE
	QObject::connect(
		abort,
		&QPushButton::clicked,
		[this]() {
			printf("abort\n");
			//this->dialog.hide();
		}
	);

	// TODO PLAN
	// name (textfield)
	// groups (picker)
	// address (textfield)
	// roles (list)
	//
	// teams(list)
	// players (list)
	// colors (color picker)
	//
	// games (list)
	this->add_role_line();
	this->add_role_line();
	this->add_role_line();
	this->select_role(1);
}

uint16_t
editorwindow::EditorWindow::add_role_line(void) {
	const uint16_t result = this->role_list.count();
	printf("the new line is at index %d\n", result);
	QListWidgetItem *const item = new QListWidgetItem;

	QLineEdit *line = new QLineEdit;
	line->setPlaceholderText("New role..."); // TODO TRANSLATE

	QObject::connect(
		line,
		&QLineEdit::returnPressed,
		[this]() { this->select_role(this->add_role_line()); }
	);

	item->setSizeHint(line->sizeHint());
	this->role_list.addItem(item);
	this->role_list.setItemWidget(item, line);

	return result;
}

void
editorwindow::EditorWindow::select_role(const uint16_t n) {
	this->role_list.setCurrentRow(n);
	this->role_list.item(n)->setSelected(true);
	this->role_list.setFocus();
	printf("locking in\n");
}
