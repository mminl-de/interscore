#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>

#include "constants.hpp"
#include "inputwindow.hpp"

inputwindow::InputWindow::InputWindow() {
	this->window.setWindowTitle("Interscore v" CONSTANTS__VERSION);

	this->start.title.setText("Interscore");

	QVBoxLayout *layout = new QVBoxLayout(&this->window);
	layout->addWidget(&this->start.title);
}
