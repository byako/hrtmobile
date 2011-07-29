#include <QtGui/QApplication>
#include <QtDeclarative>

#include <QCoreApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>
#include "hrtm_config.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

    qmlRegisterType<HrtmConfig>("HRTMConfg", 1, 0, "hrtm_config");

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();
    return app.exec();
}
