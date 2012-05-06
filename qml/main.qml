import QtQuick 1.1
import com.nokia.meego 1.0
import "updateDatabase.js" as Updater

PageStackWindow {
    id: appWindow
    initialPage: mainPage

    property int dbTimeStamp: 120321

    style: PageStackWindowStyle {
        inverted: true
    }

    MainPage {id: mainPage}
    Component.onCompleted: {
        if (Updater.updateNeeded()) {
            pageStack.push(Qt.resolvedUrl("UpdatePage.qml"))
        } else {
            mainPage.initPages()
        }
    }
}
