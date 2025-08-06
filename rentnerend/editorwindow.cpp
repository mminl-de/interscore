#include <QDialogButtonBox>
#include <QKeySequence>
#include <QObject>
#include <QPushButton>
#include <QShortcut>

#include "editorwindow.hpp"

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
	this->buttons.json_address.setText("Browse"); // TODO TRANSLATE

	// Role list
	this->labels.role_list.setText("Player roles"); // TODO TRANSLATE
	this->labels.role_list.setBuddy(&this->role_list);
	this->buttons.remove_role.setText("Remove");
	this->buttons.remove_role.setDisabled(true);
	this->role_list_input.setPlaceholderText("Add new roles here..."); // TODO TRANSLATE

	this->layouts.role_list.addWidget(&this->role_list_input);
	this->layouts.role_list.addWidget(&this->buttons.remove_role);

	QObject::connect(
		&this->role_list_input,
		&QLineEdit::returnPressed,
		&this->role_list_input,
		[this]() {
			// TODO NOW
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
	this->buttons.remove_role.setShortcut(QKeySequence("Delete"));

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

	// Action buttons
	this->buttons.abort.setText("Abort"); // TODO TRANSLATE
	this->buttons.save_and_return.setText("Save and Return"); // TODO TRANSLATE
	this->buttons.save_and_start.setText("Save and start"); // TODO TRANSLATE

	// Side layouts
	this->layouts.json_address.addWidget(&this->json_address);
	this->layouts.json_address.addWidget(&this->buttons.json_address);
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
	this->layouts.main.addLayout(&this->layouts.role_list);
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
}

void
editorwindow::EditorWindow::add_role(const QString *input) {
	QListWidgetItem *const item = new QListWidgetItem;
	QLabel *const card = new QLabel(*input);

	item->setSizeHint(card->sizeHint());
	this->role_list.addItem(item);
	this->role_list.setItemWidget(item, card);
}
