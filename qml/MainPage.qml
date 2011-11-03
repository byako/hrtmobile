import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS

Page {
    id: mainPage
    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait

    SearchDialog {
        id: searchDialog
    }

    tools: ToolBarLayout {
        ToolIcon {
            id: searchTool
            platformIconId: "toolbar-search"
            onClicked: {
                searchDialog.page = tabGroup.currentTab.loader.item
                searchDialog.open()
            }
        }
        ButtonRow {
            style: TabButtonStyle { }
            TabButton { tab: lineInfoPageContainer; text: "line"; onClicked: { lineInfoLoader.source = "lineInfo.qml"} }
            TabButton { tab: stopInfoPageContainer; text: "stop"; onClicked: { stopInfoLoader.source = "stopInfo.qml"} }
            TabButton { tab: routePageContainer;    text: "map";  onClicked: { mapLoader.source = "route.qml" } }
            TabButton { tab: settingsPageContainer; text: "opts"; onClicked: { settingsLoader.source = "settings.qml"} } //platformIconId: "toolbar-view-menu";}
        }
    }

    TabGroup {
        id: tabGroup
        anchors.fill: parent
        currentTab: lineInfoPageContainer
        Page {
            id: lineInfoPageContainer
            property Item loader: Loader {
                id: lineInfoLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("lineInfoLoader: page loaded: " + item.objectName + ".")
                        item.parent = lineInfoPageContainer
                    }
                }
            }
        }
        Page {
            id: stopInfoPageContainer
            property Item loader: Loader {
                id: stopInfoLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("stopInfoLoader: page loaded: " + item.objectName + ".")
                        item.parent = stopInfoPageContainer
                    }
                }
            }
        }
        Page {
            id: routePageContainer
            Loader {
                id: mapLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("mapLoader: page loaded: " + item.objectName + ".")
                        item.parent = routePageContainer
                    }
                }
            }
        }
        Page {
            id: settingsPageContainer
            Loader {
                id: settingsLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        console.log("settingsLoader: page loaded: " + item.objectName + ".")
                        item.parent = settingsPageContainer
                    }
                }
            }
        }
    }
}
