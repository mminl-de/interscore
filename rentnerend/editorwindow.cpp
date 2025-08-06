#include <QDialogButtonBox>
#include <QPushButton>

#include "editorwindow.hpp"

editorwindow::EditorWindow::EditorWindow(void) {
	// TODO TRANSLATE
	this->dialog.setWindowTitle("Create new tournament");
	this->dialog.setLayout(&this->layouts.main);

	this->dialog_buttons.setStandardButtons(
		QDialogButtonBox::Ok |
		QDialogButtonBox::Cancel |
		QDialogButtonBox::Apply
	);

	this->layouts.main.addWidget(new QPushButton("TODO"));
}
