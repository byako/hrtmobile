import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS

Page {
    id: mainPage
    tools: ToolBarLayout {
        id: toolBar;
        ToolIcon {
            id: searchTool
            platformIconId: "toolbar-search"
            onClicked: {
                searchDialog.page = tabGroup.currentTab.currentPage
                searchDialog.open()
                searchInput.focus = true
            }
        }
        ButtonRow {
            style: TabButtonStyle { }
            TabButton { tab: lineInfoPage; text: "line"; onClicked: { lineInfoLoader.source = "lineInfo.qml"} }
            TabButton { tab: stopInfoPage; text: "stop"; onClicked: { stopInfoLoader.source = "stopInfo.qml"} }
            TabButton { tab: routePage;    text: "map";  onClicked: { mapLoader.source = "route.qml" } }
            TabButton { tab: settingsPage; text: "opts"; onClicked: { settingsLoader.source = "settings.qml"} } //platformIconId: "toolbar-view-menu";}
        }
    }

    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait

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
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("lineInfoLoader: page loaded: " + item.objectName + ".")
                    }
                }
            }
        }
        Page {
            id: stopInfoPage
            Loader {
                id: stopInfoLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("stopInfoLoader: page loaded: " + item.objectName + ".")
                    }
                }
            }
        }
        Page{
            id: routePage
            Loader {
                id: mapLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("mapLoader: page loaded: " + item.objectName + ".")
                    }
                }
            }
        }
        Page {
            id: settingsPage
            Loader {
                id: settingsLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("settingsLoader: page loaded: " + item.objectName + ".")
                    }
                }
            }
        }
    }
}
