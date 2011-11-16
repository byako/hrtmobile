#include <QtGui/QApplication>
//#include <QtDeclarative>
#include <QDeclarativeView>
#include <QCoreApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

//c    QDeclarativeDebugHelper::enableDebugging();

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();
    return app.exec();
}
