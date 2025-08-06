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
	QPushButton *save_and_return = this->dialog_buttons.button(QDialogButtonBox::Ok);
	QPushButton *save_and_start = this->dialog_buttons.button(QDialogButtonBox::Apply);
	QPushButton *abort = this->dialog_buttons.button(QDialogButtonBox::Cancel);

	this->layouts.main.addWidget(new QPushButton("TODO"));
	this->layouts.main.addWidget(&this->dialog_buttons);

	save_and_return->setText("Save and Return"); // TODO TRANSLATE
	QObject::connect(
		save_and_return,
		&QPushButton::clicked,
		[this]() {
			this->dialog.hide();
		}
	);
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
			this->dialog.hide();
		}
	);

	// TODO PLAN
	// abort
	// save and return
	// save and start

	// TODO PLAN
	// name (textfield)
	// groups (picker)
	// address (textfield)
	// roles (list)
	// players (list)
	// games (list)
	// colors (color picker)
}
