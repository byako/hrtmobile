#include <QtGui/QApplication>
//#include <QtDeclarative>
#include <QDeclarativeView>
#include <QCoreApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>
#include "hrtm_config.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

    qmlRegisterType<HrtmConfig>("HRTMConfig", 1, 0, "HrtmConfig");

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();
    return app.exec();
}
