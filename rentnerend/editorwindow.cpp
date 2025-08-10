#include <QComboBox>
#include <QDialogButtonBox>
#include <QFileDialog>
#include <QKeySequence>
#include <QObject>
#include <QPushButton>
#include <QShortcut>

#include "editorwindow.hpp"

// TODO DEBUG MEMORY free(): invalid pointer
editorwindow::EditorWindow::EditorWindow(void) {
	this->window.setWindowTitle("Create new tournament"); // TODO TRANSLATE
	this->window.setLayout(&this->layouts.main);
	this->window.setWindowFlags(Qt::Tool | Qt::WindowStaysOnTopHint);

	// Escape closes this window
	QShortcut *esc = new QShortcut(QKeySequence(Qt::Key_Escape), &this->window);
	esc->setContext(Qt::WidgetWithChildrenShortcut);
	QObject::connect(esc, &QShortcut::activated, &this->window, &QWidget::close);

	// Tournament name
	this->labels.tournament_name.setText("Tournament name"); // TODO TRANSLATE
	this->labels.tournament_name.setBuddy(&this->tournament_name);

	// Tournament file location
	this->labels.json_address.setText("Tournament file location"); // TODO TRANSLATE
	this->labels.json_address.setBuddy(&this->json_address); // TODO TRANSLATE
	this->buttons.json_address.setAutoDefault(true);
	this->buttons.json_address.setText("Browse"); // TODO TRANSLATE

	QObject::connect(
		&this->buttons.json_address,
		&QPushButton::clicked,
		[this]() { this->select_address(); }
	);

	// Role list
	this->labels.role_list.setText("Player roles"); // TODO TRANSLATE
	this->labels.role_list.setBuddy(&this->role_list);
	this->buttons.remove_role.setAutoDefault(true);
	this->buttons.remove_role.setText("Remove");
	this->buttons.remove_role.setDisabled(true);
	this->buttons.remove_role.setShortcut(QKeySequence("Delete"));
	this->role_list_input.setPlaceholderText("Add new roles here..."); // TODO TRANSLATE

	this->layouts.role_list_input.addWidget(&this->role_list_input);
	this->layouts.role_list_input.addWidget(&this->buttons.remove_role);

	QObject::connect(
		&this->role_list_input,
		&QLineEdit::returnPressed,
		[this]() {
			const QString input = this->role_list_input.text();
			this->role_list_input.clear();
			this->add_role(&input);
		}
	);

	// Show the Remove button when selection changes
	QObject::connect(
		&this->role_list,
		&QListWidget::itemSelectionChanged,
		[this]() {
			this->buttons.remove_role.setEnabled(
				!this->role_list.selectedItems().isEmpty()
			);
		}
	);

	// Remove the selected item when button is clicked
	QObject::connect(
		&this->buttons.remove_role,
		&QPushButton::clicked,
		[this]() {
			QList<QListWidgetItem *> selected = this->role_list.selectedItems();
			for (QListWidgetItem *item : selected) {
				int32_t row = this->role_list.row(item);
				QListWidgetItem *removed = this->role_list.takeItem(row);
				delete removed;  // also deletes associated widget
			}
		}
	);

	// Team list
	this->labels.team_list.setText("Participating teams"); // TODO TRANSLATE
	this->labels.team_list.setBuddy(&this->team_list);
	this->buttons.remove_team.setAutoDefault(true);
	this->buttons.remove_team.setText("Remove");
	this->buttons.remove_team.setDisabled(true);
	this->role_list_input.setPlaceholderText("Add new teams here..."); // TODO TRANSLATE

	this->layouts.team_list_input.addWidget(&this->team_list_input);
	this->layouts.team_list_input.addWidget(&this->buttons.remove_team);

	// Player list
	this->labels.player_list.setText("Participating players"); // TODO TRANSLATE
	this->labels.player_list.setBuddy(&this->player_list);
	this->buttons.remove_player.setAutoDefault(true);
	this->buttons.remove_player.setText("Remove");
	this->buttons.remove_player.setDisabled(true);
	this->role_list_input.setPlaceholderText("Add new players here..."); // TODO TRANSLATE

	this->layouts.player_list_input.addWidget(&this->player_list_input);
	this->layouts.player_list_input.addWidget(&this->buttons.remove_player);

	// Game list
	this->labels.game_list.setText("Games"); // TODO TRANSLATE
	this->buttons.add_game.setAutoDefault(true);
	this->buttons.add_game.setText("+"); // TODO TRANSLATE
	this->buttons.remove_game.setAutoDefault(true);
	this->buttons.remove_game.setText("-"); // TODO TRANSLATE

	// Left game list adds a new game
	QObject::connect(
		&this->buttons.add_game,
		&QPushButton::clicked,
		[this]() { this->add_game(); }
	);

	// Action buttons
	this->buttons.abort.setAutoDefault(true);
	this->buttons.abort.setText("Abort"); // TODO TRANSLATE
	this->buttons.save_and_return.setAutoDefault(true);
	this->buttons.save_and_return.setText("Save and Return"); // TODO TRANSLATE
	this->buttons.save_and_start.setAutoDefault(true);
	this->buttons.save_and_start.setText("Save and start"); // TODO TRANSLATE

	// Side layouts
	this->layouts.json_address.addWidget(&this->json_address);
	this->layouts.json_address.addWidget(&this->buttons.json_address);

	this->layouts.team_list.addWidget(&this->labels.team_list);
	this->layouts.team_list.addWidget(&this->team_list);
	this->layouts.team_list.addLayout(&this->layouts.team_list_input);

	this->layouts.player_list.addWidget(&this->labels.player_list);
	this->layouts.player_list.addWidget(&this->player_list);
	this->layouts.player_list.addLayout(&this->layouts.player_list_input);

	this->layouts.team_player_lists.addLayout(&this->layouts.team_list);
	this->layouts.team_player_lists.addLayout(&this->layouts.player_list);

	this->layouts.game_list.addWidget(&this->buttons.add_game);
	this->layouts.game_list.addWidget(&this->buttons.remove_game);

	this->layouts.action_buttons.addWidget(&this->buttons.abort);
	this->layouts.action_buttons.addWidget(&this->buttons.save_and_return);
	this->layouts.action_buttons.addWidget(&this->buttons.save_and_start);

	// Main layout
	this->layouts.main.addWidget(&this->labels.tournament_name);
	this->layouts.main.addWidget(&this->tournament_name);
	this->layouts.main.addWidget(&this->labels.json_address);
	this->layouts.main.addLayout(&this->layouts.json_address);
	this->layouts.main.addWidget(&this->labels.role_list);
	this->layouts.main.addWidget(&this->role_list);
	this->layouts.main.addLayout(&this->layouts.role_list_input);
	this->layouts.main.addLayout(&this->layouts.team_player_lists);
	this->layouts.main.addWidget(&this->labels.game_list);
	this->layouts.main.addWidget(&this->game_list);
	this->layouts.main.addLayout(&this->layouts.game_list);
	this->layouts.main.addLayout(&this->layouts.action_buttons);

	// TODO NOW

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

	// TODO PLAN NOW
	// add and remove games
	// add and remove teams
	// add and remove players
	// proceed
}

void
editorwindow::EditorWindow::select_address(void) {
	const QString filter = "JSON Files (*.json)";
	QFileDialog dialog(nullptr, "Select tournament", nullptr, filter);
	dialog.setNameFilter(filter);
	dialog.setOption(QFileDialog::DontUseNativeDialog, false);

	if (dialog.exec() != QDialog::Accepted) return;
	this->json_address.setText(dialog.selectedFiles().first());
}

void
editorwindow::EditorWindow::add_role(const QString *input) {
	QListWidgetItem *const item = new QListWidgetItem;
	QLabel *const card = new QLabel(*input);

	item->setSizeHint(card->sizeHint());
	this->role_list.addItem(item);
	this->role_list.setItemWidget(item, card);
}

void
editorwindow::EditorWindow::add_game(void) {
	QListWidgetItem *const item = new QListWidgetItem;
	QWidget *const card = new QWidget;
	QHBoxLayout *const layout = new QHBoxLayout(card);

	QComboBox *const left_team = new QComboBox;
	QLabel *const vs = new QLabel("vs.");
	QComboBox *const right_team = new QComboBox;

	left_team->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
	right_team->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);

	layout->addWidget(left_team);
	layout->addWidget(vs);
	layout->addWidget(right_team);
	card->setLayout(layout);

	item->setSizeHint(card->sizeHint());
	this->game_list.addItem(item);
	this->game_list.setItemWidget(item, card);
}
