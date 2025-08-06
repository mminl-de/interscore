#pragma once

#include <QDialog>
#include <QDialogButtonBox>
#include <QVBoxLayout>
#include <QWidget>

namespace editorwindow {

struct EditorWindow {
	QDialog dialog;
	QDialogButtonBox dialog_buttons;

	struct {
		QVBoxLayout main;
	} layouts;

	EditorWindow(void);

	// TODO PLAN
	// name (textfield)
	// groups (picker)
	// address (textfield)
	// roles (list)
	// players (list)
	// games (list)
	// colors (color picker)
};

} // namespace editorwindow
