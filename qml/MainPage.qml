import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS

Page {
    id: mainPage
    tools: ToolBarLayout {
        id: toolBar;
        ToolIcon {
             id: backTool
             platformIconId: "toolbar-back"
             onClicked: {
                 tabGroup.currentTab.pop()
             }
        }
        ToolIcon {
            id: searchTool
            platformIconId: "toolbar-search"
            onClicked: {
                searchDialog.page = tabGroup.currentTab.currentPage
                searchDialog.open()
//                searchInput.focus = true
            }
        }
        ButtonRow {
            style: TabButtonStyle { }
            TabButton { tab: lineInfoPage; text: "line" }
            TabButton { tab: stopInfoPage; text: "stop" }
            TabButton { tab: routePage; text: "map" }
            TabButton { tab: settingsPage; text: "opts" }
        }
    }

    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        lineInfoPage.push(Qt.resolvedUrl("lineInfo.qml"));
        stopInfoPage.push(Qt.resolvedUrl("stopInfo.qml"));
        settingsPage.push(Qt.resolvedUrl("settings.qml"));
    }
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
        PageStack {
            id: lineInfoPage
        }
        PageStack {
            id: stopInfoPage
        }
        PageStack {
            id: routePage
        }
        PageStack {
            id: settingsPage
        }
    }
}
