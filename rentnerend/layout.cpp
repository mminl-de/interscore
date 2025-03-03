#include <QApplication>
#include <QFont>
#include <QHBoxLayout>
#include <QLabel>
#include <QResizeEvent>
#include <QVBoxLayout>
#include <QWidget>

class DynamicQWidget : public QWidget {
    QVBoxLayout *layout;
    QLabel *time;
    QLabel *t1;
    QLabel *s1;
    QLabel *t2;
    QLabel *s2;

public:
    DynamicQWidget() {
        this->setWindowTitle("InterScore – Display window");

        layout = new QVBoxLayout;
        layout->setAlignment(Qt::AlignCenter);
        layout->setSpacing(200);

        QWidget *teams = new QWidget;
        teams->setStyleSheet("background-color: purple;");
        QHBoxLayout *teams_layout = new QHBoxLayout;
        teams->setLayout(teams_layout);

        QWidget *team_1 = new QWidget;
        team_1->setStyleSheet("background-color: red;");
        QVBoxLayout *team_1_layout = new QVBoxLayout;
        team_1->setLayout(team_1_layout);

        QFont font("JetBrains Mono", 100);
        t1 = new QLabel("GIFHORN", this);
        t1->setAlignment(Qt::AlignCenter);
        t1->setFont(font);
        t1->setFixedWidth(800);
        s1 = new QLabel("69", this);
        s1->setStyleSheet("background-color: pink;");
        s1->setFont(font);
        s1->setAlignment(Qt::AlignCenter);
        team_1_layout->addWidget(t1);
        team_1_layout->addWidget(s1);

        QWidget *team_2 = new QWidget;
        team_2->setStyleSheet("background-color: blue;");
        QVBoxLayout *team_2_layout = new QVBoxLayout;
        team_2->setLayout(team_2_layout);

        t2 = new QLabel("LUDWIGSFELDE", this);
        t2->setAlignment(Qt::AlignCenter);
        t2->setFont(font);
        t2->setFixedWidth(800);
        s2 = new QLabel("420", this);
        s2->setStyleSheet("background-color: cyan;");
        s2->setFont(font);
        s2->setAlignment(Qt::AlignCenter);
        team_2_layout->addWidget(t2);
        team_2_layout->addWidget(s2);

        teams_layout->addWidget(team_1);
        teams_layout->addWidget(team_2);

        layout->addWidget(teams);

        time = new QLabel("07:00", this);
        time->setStyleSheet("background-color: green;");
        time->setFont(font);
        time->setAlignment(Qt::AlignCenter);
        layout->addWidget(time);

        this->setLayout(layout);
    }

protected:
    void resizeEvent(QResizeEvent *event) override {
        // Get the new window size
        int width = event->size().width();
        int height = event->size().height();

        // Calculate the font size as a percentage of window height
        int newFontSize = height / 10;  // Adjust this factor based on your preference

        // Set the new font size to labels
        QFont font = time->font();
        font.setPointSize(newFontSize);
        s1->setFont(font);
        s2->setFont(font);
        time->setFont(font);

        font.setPointSize(newFontSize >> 1);
        t1->setFont(font);
        t2->setFont(font);
        layout->setSpacing(newFontSize * 3);
        t1->setFixedWidth(newFontSize * 7);
        t2->setFixedWidth(newFontSize * 7);

        QWidget::resizeEvent(event);  // Call the base class handler
    }
};

struct DisplayWindow {
    DynamicQWidget *wid;

    DisplayWindow() {
        wid = new DynamicQWidget;
    }

    // TODO CONSIDER ~DisplayWindow()
};

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    DisplayWindow dw;

    dw.wid->show();
    return app.exec();
}


