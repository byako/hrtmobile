import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    id: appWindow
    initialPage: mainPage

    property int dbTimeStamp: 120321

    style: PageStackWindowStyle {
        inverted: true
    }

    MainPage {id: mainPage}
}
