#pragma once

#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QWidget>

namespace editorwindow {

struct EditorWindow {
	QWidget window;

	struct {
		QVBoxLayout main;
		QHBoxLayout json_address;
		QHBoxLayout role_list;
		QHBoxLayout action_buttons;
	} layouts;
	struct {
		QLabel tournament_name;
		QLabel json_address;
		QLabel role_list;
	} labels;
	struct {
		QPushButton json_address;
		QPushButton remove_role;
		QPushButton abort;
		QPushButton save_and_return;
		QPushButton save_and_start;
	} buttons;

	QLineEdit tournament_name;
	QLineEdit json_address;
	QListWidget role_list;
	QLineEdit role_list_input;

	EditorWindow(void);

	// Add the name of a role to the role list.
	void add_role(const QString *input);
};

} // namespace editorwindow
