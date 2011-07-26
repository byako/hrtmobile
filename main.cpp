#include <QtGui/QApplication>
#include <QtDeclarative>

#include <QCoreApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>
#include <QDebug>
#include <QtNetwork>
//#include <QtNetwork/QNetworkRequest>
//#include <QtNetwork/QNetworkReply>
#include <stdio.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();
    return app.exec();
}
