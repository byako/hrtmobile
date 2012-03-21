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
    Component.onCompleted: {
        console.log("starting databaseUpdater")
        Updater.check_if_update_needed(dbTimeStamp)
    }

    MainPage {id: mainPage}
}
