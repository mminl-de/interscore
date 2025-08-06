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
			//this->dialog.hide();
		}
	);

	// TODO PLAN
	// name (textfield)
	// groups (picker)
	// address (textfield)
	// roles (list)
	// players (list)
	// games (list)
	// colors (color picker)
	this->add_role_line();
}

void
editorwindow::EditorWindow::add_role_line(void) {
	QListWidgetItem *const result = new QListWidgetItem;

	QLineEdit *line = new QLineEdit;
	line->setPlaceholderText("New role..."); // TODO TRANSLATE

	QObject::connect(
		line,
		&QLineEdit::returnPressed,
		[this] () { this->add_role_line(); }
	);

	result->setSizeHint(line->sizeHint());
	this->role_list.addItem(result);
	this->role_list.setItemWidget(result, line);
}
