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
		QHBoxLayout role_list_input;
		QVBoxLayout team_list;
		QHBoxLayout team_list_input;
		QVBoxLayout player_list;
		QHBoxLayout player_list_input;
		QHBoxLayout team_player_lists;
		QHBoxLayout game_list;
		QHBoxLayout action_buttons;
	} layouts;
	struct {
		QLabel tournament_name;
		QLabel json_address;
		QLabel role_list;
		QLabel team_list;
		QLabel player_list;
		QLabel game_list;
	} labels;
	struct {
		QPushButton json_address;
		QPushButton remove_role;
		QPushButton remove_team;
		QPushButton remove_player;
		QPushButton add_game;
		QPushButton remove_game;
		QPushButton abort;
		QPushButton save_and_return;
		QPushButton save_and_start;
	} buttons;

	QLineEdit tournament_name;
	QLineEdit json_address;

	QListWidget role_list;
	QLineEdit role_list_input;
	QListWidget team_list;
	QLineEdit team_list_input;
	QListWidget player_list;
	QLineEdit player_list_input;
	QListWidget game_list;

	EditorWindow(void);

protected:
	// Open a file dialog to select a single JSON file, starting from the CWD.
	// Write the selected file, if any, into the `json_address` text field.
	void select_address(void);

	// Add the name of a role to the role list.
	void add_role(const QString *input);

	// Add a widget for a new game to the game list.
	void add_game(void);
};

} // namespace editorwindow
