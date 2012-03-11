import QtQuick 1.1
import com.nokia.meego 1.0
//import "updateDatabase.js" as updater

PageStackWindow {
    id: appWindow
    initialPage: mainPage
    style: PageStackWindowStyle {
        inverted: true
    }
//    property int dbTimeStamp : 120222
    MainPage {id: mainPage}
}
