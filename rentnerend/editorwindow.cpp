#include <QColorDialog>
#include <QComboBox>
#include <QDialogButtonBox>
#include <QFileDialog>
#include <QFrame>
#include <QKeySequence>
#include <QPushButton>
#include <QShortcut>

#include "editorwindow.hpp"

using EditorWindow = editorwindow::EditorWindow;

// TODO DEBUG MEMORY free(): invalid pointer
EditorWindow::EditorWindow(void) {
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

	this->layouts.json_address.addWidget(&this->json_address);
	this->layouts.json_address.addWidget(&this->buttons.json_address);

	// Open a file dialog when pressing the Browse button
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

	// Add string to role list when pressing Return/Enter in the role text field
	QObject::connect(
		&this->role_list_input,
		&QLineEdit::returnPressed,
		[this]() {
			const QString input = this->role_list_input.text();
			this->role_list_input.clear();
			this->add_role(&input);
		}
	);

	// Make the Remove button usable when a role is selected
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
	this->default_player_list.addItem("[No players]"); // TODO TRANSLATE
	this->data.current_players = &this->default_player_list;
	this->data.current_team = nullptr;

	this->labels.team_list.setText("Participating teams"); // TODO TRANSLATE
	this->labels.team_list.setBuddy(&this->team_list);
	this->buttons.remove_team.setAutoDefault(true);
	this->buttons.remove_team.setText("Remove");
	this->buttons.remove_team.setDisabled(true);
	// TODO DEBUG it's not good if there multiple such buttons
	this->buttons.remove_team.setShortcut(QKeySequence("Delete"));
	this->team_list_input.setPlaceholderText("Team name..."); // TODO TRANSLATE

	this->layouts.team_list_input.addWidget(&this->team_list_input);
	this->layouts.team_list_input.addWidget(&this->buttons.remove_team);

	this->layouts.team_list.addWidget(&this->labels.team_list);
	this->layouts.team_list.addWidget(&this->team_list);
	this->layouts.team_list.addLayout(&this->layouts.team_list_input);

	// Add string to team list when pressing Return/Enter in the team text field
	QObject::connect(
		&this->team_list_input,
		&QLineEdit::returnPressed,
		[this]() {
			const QString input = this->team_list_input.text();
			if (this->data.player_lists.contains(input))
				return;

			this->data.player_lists.insert(input, new QListWidget);
			this->team_list_input.clear();
			this->add_team(&input);
		}
	);

	// Show the Remove button when selection changes and make the player list
	// usable only when a team is selected
	QObject::connect(
		&this->team_list,
		&QListWidget::itemSelectionChanged,
		[this]() {
			// Determine new selected item. (1)
			const QList<QListWidgetItem *> selected_items =
				this->team_list.selectedItems();

			// Hide Remove Team button if there are no teams.
			if (selected_items.isEmpty()) {
				this->buttons.remove_team.setEnabled(false);
				this->player_list_frame.setEnabled(false);
				this->labels.player_list.setText("Players of"); // TODO TRANSLATE
				// TODO NOW
				//this->layouts.player_list.replaceWidget(
				//	this->data.current_team,
				//	&this->default_player_list
				//);
				return;
			}

			// Unhide Remove Team button if there are yes teams.
			this->buttons.remove_team.setEnabled(true);
			this->player_list_frame.setEnabled(true);

			// Determine new selected item. (2)
			QListWidgetItem *item = selected_items.first();
			if (!item) return;

			// Deconstruct widget step by step to find the label of the selected item.
			const QWidget *card = this->team_list.itemWidget(item);
			const QHBoxLayout *layout = qobject_cast<QHBoxLayout *>(card->layout());
			const QLabel *label = qobject_cast<QLabel *>(layout->itemAt(0)->widget());

			if (!label) return;
			this->data.current_team = label->text();
			this->labels.player_list.setText(
				"Players of " + this->data.current_team
			); // TODO TRANSLATE

			// Replace player list with the one of the new team.
			QListWidget *new_list =
				this->data.player_lists.value(this->data.current_team);
			for(int i=0; i < new_list->count(); i++) { // TODO TEST
				// TODO NOTE it is there but no text is home :(
				QListWidgetItem *item = new_list->item(i);
				QWidget *card = new_list->itemWidget(item);
				QString text = qobject_cast<QLabel *>(card)->text();

				printf("ITEM %d. %s\n", i, text.toStdString().c_str());
			}
			printf("---\n");
			this->layouts.player_list.replaceWidget(this->data.current_players, new_list);
			// TODO COMMENT
			this->data.current_players->hide();
			new_list->show();
			this->layouts.player_list.invalidate();
			this->data.current_players = new_list;
		}
	);

	// Remove the selected item when button is clicked
	QObject::connect(
		&this->buttons.remove_team,
		&QPushButton::clicked,
		[this]() {
			QList<QListWidgetItem *> selected = this->team_list.selectedItems();
			for (QListWidgetItem *item : selected) {
				int32_t row = this->team_list.row(item);
				QListWidgetItem *removed = this->team_list.takeItem(row);

				const QString text = removed->text();

				// TODO NOW
				// i have a fundamental logical flaw in how i reference list items
				// ie there is a different type in the QHash
				//
				// maybe you should move this code too
				if (this->data.player_lists.value(text) == this->data.current_players) {
					this->layouts.player_list.replaceWidget(
						this->data.current_players,
						&this->default_player_list
					);
					// TODO COMMENT
					this->data.current_players->hide();
					this->default_player_list.show();
					this->layouts.player_list.invalidate();
					this->data.current_team = nullptr;
				}

				delete removed;  // also deletes associated widget
				delete this->data.player_lists.value(text);
				this->data.player_lists.remove(text);
			}
		}
	);

	// Player list
	this->labels.player_list.setText("Players of"); // TODO TRANSLATE
	this->labels.player_list.setBuddy(this->data.current_players);
	this->buttons.remove_player.setAutoDefault(true);
	this->buttons.remove_player.setText("Remove");
	this->buttons.remove_player.setDisabled(true);
	this->player_list_input.setPlaceholderText("Player name..."); // TODO TRANSLATE

	this->layouts.player_list_input.addWidget(&this->player_list_input);
	this->layouts.player_list_input.addWidget(&this->buttons.remove_player);

	this->layouts.player_list.addWidget(&this->labels.player_list);
	this->layouts.player_list.addWidget(this->data.current_players);
	this->layouts.player_list.addLayout(&this->layouts.player_list_input);

	this->player_list_frame.setLayout(&this->layouts.player_list);
	this->player_list_frame.setFrameShape(QFrame::Box);
	this->player_list_frame.setFrameShadow(QFrame::Plain);
	this->player_list_frame.setLineWidth(1);
	this->player_list_frame.setEnabled(false);

	// Add string to player list when pressing Return/Enter in the role text field
	QObject::connect(
		&this->player_list_input,
		&QLineEdit::returnPressed,
		[this]() {
			const QString input = this->player_list_input.text();
			this->player_list_input.clear();
			this->add_player(&input);
			// TODO NOW remove all useless occurences of this->data.current_team
		}
	);

	// Remove the selected player when button is clicked
	QObject::connect(
		&this->buttons.remove_player,
		&QPushButton::clicked,
		[this]() {
			QList<QListWidgetItem *> selected = this->data.current_players->selectedItems();
			for (QListWidgetItem *item : selected) {
				int32_t row = this->data.current_players->row(item);
				QListWidgetItem *removed = this->data.current_players->takeItem(row);
				delete removed;  // also deletes associated widget
			}
		}
	);

	// Game list
	this->labels.game_list.setText("Games"); // TODO TRANSLATE
	this->buttons.add_game.setAutoDefault(true);
	this->buttons.add_game.setText("+"); // TODO TRANSLATE
	this->buttons.remove_game.setAutoDefault(true);
	this->buttons.remove_game.setText("-"); // TODO TRANSLATE

	this->layouts.game_list.addWidget(&this->buttons.add_game);
	this->layouts.game_list.addWidget(&this->buttons.remove_game);

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
	this->layouts.team_player_lists.addLayout(&this->layouts.team_list);
	this->layouts.team_player_lists.addWidget(&this->player_list_frame);

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

	// TODO ADD check whether given json address doesnt point to an existing file
}

void
EditorWindow::select_address(void) {
	const QString filter = "JSON Files (*.json)";
	QFileDialog dialog(nullptr, "Select tournament", nullptr, filter);
	dialog.setNameFilter(filter);
	dialog.setOption(QFileDialog::DontUseNativeDialog, false);

	if (dialog.exec() != QDialog::Accepted) return;
	this->json_address.setText(dialog.selectedFiles().first());
}

void
EditorWindow::add_role(const QString *input) {
	QListWidgetItem *const item = new QListWidgetItem;
	QLabel *const card = new QLabel(*input);

	item->setSizeHint(card->sizeHint());
	this->role_list.addItem(item);
	this->role_list.setItemWidget(item, card);
}

void
EditorWindow::add_team(const QString *input) {
	QListWidgetItem *const item = new QListWidgetItem;
	QWidget *const card = new QWidget;
	QHBoxLayout *const layout = new QHBoxLayout(card);

	QLabel *const label = new QLabel(*input);
	QPushButton *const color = new QPushButton;
	color->setText("#ff0000");
	color->setStyleSheet("background-color: #ff0000;");

	QObject::connect(
		color,
		&QPushButton::clicked,
		[color]() {
			const QColor current_color(color->text());
			const QColor selection =
				QColorDialog::getColor(current_color, nullptr, "Choose team color"); // TODO TRANSLATE
			if (!selection.isValid()) return;
			const QString hexcode = selection.name();
			color->setText(hexcode);
			color->setStyleSheet(QString("background-color: %1;").arg(hexcode));
		}
	);

	layout->addWidget(label);
	layout->addWidget(color);
	card->setLayout(layout);

	item->setSizeHint(card->sizeHint());
	this->team_list.addItem(item);
	this->team_list.setItemWidget(item, card);
}

void
EditorWindow::add_player(const QString *input) {
	QListWidgetItem *const item = new QListWidgetItem;
	QLabel *const card = new QLabel(*input);

	item->setSizeHint(card->sizeHint());
	this->data.current_players->addItem(item);
	this->data.current_players->setItemWidget(item, card);
}

void
EditorWindow::add_game(void) {
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
