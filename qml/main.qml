import QtQuick 1.1
import com.nokia.meego 1.0
import "updateDatabase.js" as Updater

PageStackWindow {
    id: appWindow

    style: PageStackWindowStyle {
        inverted: true
    }

    Component.onCompleted: {
        if (!validated()) {
            pushMainPage()
        }
    }

    MainPage {id: mainPage}

    function validated() {
        console.log("MainPage.qml: init check for reset request")
        if (Updater.resetNeeded() == 1) {
            console.log("MainPage.qml: cleaning database")
            var temp = Updater.resetDatabase();
            if (temp != 0) {
                console.log("MainPage.qml: DB clean failed. Error:" + temp)
            } else {
                console.log("MainPage.qml: DB cleaned")
            }
            return 0; // validated somehow
        } else {
            if (Updater.updateNeeded() == 1) {
                console.log("MainPage.qml: pushing updater page")
                pageStack.push(Qt.resolvedUrl("UpdatePage.qml"))
                return 1;
            } else {
                console.log("main: validated = 0");
                return 0;
            }
        }
    }

    function pushMainPage() {
        pageStack.push(mainPage)
        mainPage.initPages()
    }
}
