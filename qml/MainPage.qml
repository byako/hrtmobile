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
/*        ToolIcon {
            id: searchTool
            platformIconId: "toolbar-search"
            onClicked: {
                searchDialog.page = tabGroup.currentTab.loader.item
                searchDialog.open()
            }
        }*/
        ButtonRow {
            style: TabButtonStyle { }
            TabButton {
                tab: lineInfoPageContainer;
                text: (checked) ? "" : "line";
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search" : ""
                onClicked: {
                     if (tabGroup.lastTab == 0 && lineInfoLoader.status == Loader.Ready) {
                         searchDialog.page = lineInfoLoader.item
                         searchDialog.open()
                     } else if (lineInfoLoader.status != Loader.Ready){
                        lineInfoLoader.source = "lineInfo.qml"
                     }
                     tabGroup.lastTab = 0
                }
            }
            TabButton {
                tab: stopInfoPageContainer;
                text: (checked) ? "" : "stop";
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search" : ""
                onClicked: {
                    if (tabGroup.lastTab == 1 && stopInfoLoader.status == Loader.Ready) {
                        searchDialog.page = stopInfoLoader.item
                        searchDialog.open()
                    } else if (stopInfoLoader.status != Loader.Ready){
                        stopInfoLoader.source = "stopInfo.qml"
                    }
                    tabGroup.lastTab = 1
                }
            }
            TabButton {
                tab: routePageContainer
                text: (checked) ? "" : "map";
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search" : ""
                onClicked: {
                    if (tabGroup.lastTab == 2 && mapLoader.status == Loader.Ready) {
                        searchDialog.page = mapLoader.item
                        searchDialog.open()
                    } else if (mapLoader.status != Loader.Ready){
                        mapLoader.source = "route.qml"
                    }
                    tabGroup.lastTab = 2
                }
            }
            TabButton {
                tab: settingsPageContainer;
                text: "opts";
                onClicked: {
                    if (settingsLoader.status != Loader.Ready){
                        settingsLoader.source = "settings.qml"
                    }
                    tabGroup.lastTab = 3
                }
            }
        }
    }

    TabGroup {
        id: tabGroup
        anchors.fill: parent
        currentTab: lineInfoPageContainer
        property int lastTab: 0
        Page {
            id: lineInfoPageContainer
            property Item loader: Loader {
                id: lineInfoLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
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
                        item.parent = settingsPageContainer
                    }
                }
            }
        }
    }
}
