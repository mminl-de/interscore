#include <QHBoxLayout>
#include <QVBoxLayout>

#include "displaywindow.hpp"

#define ORANGE "#f60" // TODO NOW

displaywindow::DisplayWindow::DisplayWindow() {
	this->window.setWindowTitle("Interscore: Scoreboard Display");

	// Setting colors
	this->window.setStyleSheet("background-color: black");
	this->labels.t1.name.setStyleSheet("font-size: 130px; color: white;");
	this->labels.t1.score.setStyleSheet("font-size: 600px; color:" ORANGE ";");
	this->labels.t2.name.setStyleSheet("font-size: 130px; color: white;");
	this->labels.t2.score.setStyleSheet("font-size: 600px; color:" ORANGE ";");
	this->labels.time.setStyleSheet("font-size: 500px; color: white;");
	this->labels.colon.setStyleSheet("font-size: 600px; color: white;");

	// Centering everything everywhere
	this->labels.t1.name.setAlignment(Qt::AlignCenter);
	this->labels.t1.score.setAlignment(Qt::AlignCenter);
	this->labels.t2.name.setAlignment(Qt::AlignCenter);
	this->labels.t2.score.setAlignment(Qt::AlignCenter);
	this->labels.time.setAlignment(Qt::AlignCenter);
	this->labels.colon.setAlignment(Qt::AlignCenter);

	// Filling in content
	this->labels.t1.name.setText("Team 1");
	this->labels.t1.score.setText("0");
	this->labels.t2.name.setText("Team 2");
	this->labels.t2.score.setText("0");
	this->labels.time.setText("0.00");
	this->labels.colon.setText(":");

	// Structuring
	QHBoxLayout *top_bar = new QHBoxLayout;
	top_bar->addWidget(&this->labels.t1.name);
	top_bar->addWidget(&this->labels.t2.name);

	QHBoxLayout *middle_bar = new QHBoxLayout;
	middle_bar->addWidget(&this->labels.t1.score, 3);
	middle_bar->addWidget(&this->labels.colon, 1);
	middle_bar->addWidget(&this->labels.t2.score, 3);

	QVBoxLayout *layout = new QVBoxLayout(&this->window);
	layout->addLayout(top_bar, 1);
	layout->addLayout(middle_bar, 2);
	layout->addWidget(&this->labels.time, 2);
}
