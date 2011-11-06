import QtQuick 1.1
import com.meego 1.0
import "database.js" as JS

Page {
    id: mainPage
    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait
    Config { id: config }
    Rectangle{      // dark background
        color: config.bgColor
        anchors.fill: parent
    }

    Component.onCompleted: { JS.loadConfig(config) }

    SearchDialog {
        id: searchDialog
    }
    tools: ToolBarLayout {
        ButtonRow {
            id: mainTabBar
            style: TabButtonStyle {
                inverted: true
            }
            TabButton {
                id: recentTabButton
                tab: recentPageContainer;
                text: (checked) ? "" : "rcnt";
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search-white" : ""
                onClicked: {
                     tabGroup.lastTab = -1
                }
            }
            TabButton {
                id: linesTabButton
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
                id: stopsTabButton
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
                id: mapTabButton
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
                id: settingsTabButton
                tab: settingsPageContainer;
                //text: "opts";
                iconSource: (checked) ? "image://theme/icon-m-toolbar-view-menu-white-selected" : "image://theme/icon-m-toolbar-view-menu-white"
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
        currentTab: recentPageContainer
        property int lastTab: -1
        Page {   // recents page
            id: recentPageContainer
            Label {
                style: LabelStyle {
                    inverted: true
                }
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "Recent lines/stops/places"
                    font.pixelSize: 25
                }
            }

            property Item loader: Loader {
                id: recentLoader
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        item.parent = recentPageContainer
                    }
                }
            }
        }

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
        Connections {
            target: settingsLoader.item
            onUpdateConfig: {
                console.log("updating config")
                if (lineInfoLoader.status == Loader.Ready) lineInfoLoader.item.refreshConfig()
                if (stopInfoLoader.status == Loader.Ready) stopInfoLoader.item.refreshConfig()
                if (settingsLoader.status == Loader.Ready) settingsLoader.item.refreshConfig()
            }
        }
        Connections {
            target: lineInfoLoader.item
            onShowLineMap: {
                console.log("lineInfo signal: showLineMap")
                initMap(lineIdLong, "")
            }
            onShowLineMapStop: {
                console.log("lineInfo signal: showLineMapStop")
                initMap(lineIdLong, stopIdLong)
            }
            onShowStopMap: {
                console.log("lineInfo signal: showStopMap")
                initMap()
                initMap("", stopIdLong)
            }
            onShowStopInfo: {
                console.log("lineInfo signal: showStopInfo")
                if (stopInfoLoader.status!= Loader.Ready) {
                    stopInfoLoader.source = "stopInfo.qml"
                    tabGroup.lastTab = 1
                    mainTabBar.checkedButton = stopsTabButton
                    tabGroup.currentTab = stopInfoPageContainer
                }
                stopInfoLoader.item.searchString = stopIdLong
                stopInfoLoader.item.buttonClicked()
            }
        }
        Connections {
            target: stopInfoLoader.item
            onShowStopMap: {
                console.log("stopInfo signal: showStopMap")
                initMap("", stopIdLong)
            }
            onShowStopMapLine: {
                console.log("stopInfo signal: showStopMapLine")
                initMap(lineIdLong, stopIdLong)
            }
            onShowLineMap: {
                console.log("stopInfo signal: showLineMap")
                initMap(lineIdLong, "")
            }
            onShowLineInfo: {
                console.log("stopInfo signal: showLineInfo")
                if (lineInfoLoader.status!= Loader.Ready) {
                    lineInfoLoader.source = "lineInfo.qml"
                    tabGroup.lastTab = 0
                    mainTabBar.checkedButton = linesTabButton
                    tabGroup.currentTab = lineInfoPageContainer
                }
                lineInfoLoader.item.searchString = lineIdLong
                lineInfoLoader.item.buttonClicked()
            }
        }
    }
    function initMap(lineIdLong_, stopIdLong_) {
        if (mapLoader.status != Loader.Ready) {
            mapLoader.source = "route.qml"
        }
        tabGroup.lastTab = 2
        mainTabBar.checkedButton = mapTabButton
        tabGroup.currentTab = routePageContainer

        mapLoader.item.loadLine = lineIdLong_
        mapLoader.item.loadStop = stopIdLong_
        mapLoader.item.checkLoadStop()
        mapLoader.item.checkLoadLine()
    }
}
