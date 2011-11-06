import QtQuick 1.1
import com.meego 1.0

PageStackWindow {
    id: appWindow
    initialPage: mainPage
    style: PageStackWindowStyle {
        inverted: true
    }
    MainPage {id: mainPage}
}
