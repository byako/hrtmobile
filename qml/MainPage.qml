import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS

Page {
    id: mainPage
    tools: ToolBarLayout {
        id: toolBar;
        ButtonRow {
            style: TabButtonStyle { }
            TabButton { tab: lineInfoPage; text: "lines" }
            TabButton { tab: stopInfoPage; text: "stops" }
            TabButton { tab: mapPage; text: "map" }
            TabButton { tab: settingsPage; text: "opts" }
        }
    }

    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: { }
    Rectangle{    // dark background
        color: "#000000"
        anchors.fill: parent
        width: parent.width
        height:  parent.height
    }

    TabGroup {
        id: tabGroup
        anchors.fill: parent
        currentTab: lineInfoPage

        Page {
            id: lineInfoPage
            Loader {
                id: lineInfoLoader
                source: "lineInfo.qml"
            }
        }
        Page {
            id: stopInfoPage
            Loader {
                id: stopInfoLoader
                source: "stopInfo.qml"
            }
        }
        Page {
            id: mapPage
            Loader {
                id: mapLoader
//                source: "route.qml"
            }
        }
        Page {
            id: settingsPage
            Loader {
                id: settingsLoader
                source: "settings.qml"
            }
        }
    }
}
