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
		QHBoxLayout role_list_buttons;
		QHBoxLayout action_buttons;
	} layouts;
	struct {
		QLabel tournament_name;
		QLabel json_address;
		QLabel role_list;
	} labels;
	struct {
		QPushButton json_address;
	} buttons;

	QLineEdit tournament_name;
	QLineEdit json_address;
	QListWidget role_list;

	EditorWindow(void);
};

} // namespace editorwindow
