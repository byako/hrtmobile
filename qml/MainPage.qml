import QtQuick 1.1
import com.nokia.meego 1.0
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
        page: recentPageContainer
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
                iconSource:  "image://theme/icon-m-toolbar-favorite-unmark-white" //"image://theme/icon-m-toolbar-frequent-used-white"
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
                        lineInfoLoader.parent = lineInfoPageContainer
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
                        stopInfoLoader.parent = stopInfoPageContainer
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
        currentTab: recentPageContainer
        property int lastTab: -1
        Page {   // recents page
            id: recentPageContainer
            Label {
                style: LabelStyle { inverted: true }
                anchors.centerIn: parent
                text: "Recent lines/stops/places"
            }
        }

        Page {
            id: lineInfoPageContainer
            Loader {
                id: lineInfoLoader
            }
        }
        Page {
            id: stopInfoPageContainer
            Loader {
                id: stopInfoLoader
            }
        }
        Page {
            id: routePageContainer
            Loader {
                id: mapLoader
            }
        }
        Page {
            id: settingsPageContainer
            Loader {
                id: settingsLoader
            }
        }
        Connections {  // settings
            target: settingsLoader.item
            onUpdateConfig: {
                console.log("updating config")
                if (lineInfoLoader.status == Loader.Ready) lineInfoLoader.item.refreshConfig()
                if (stopInfoLoader.status == Loader.Ready) stopInfoLoader.item.refreshConfig()
                if (settingsLoader.status == Loader.Ready) settingsLoader.item.refreshConfig()
            }
        }
        Connections {  // line info
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
                initMap("", stopIdLong)
            }
            onShowStopInfo: {
                console.log("lineInfo signal: showStopInfo")
                if (stopInfoLoader.status!= Loader.Ready) {
                    stopInfoLoader.source = "stopInfo.qml"
                }
                tabGroup.lastTab = 1
                mainTabBar.checkedButton = stopsTabButton
                tabGroup.currentTab = stopInfoPageContainer
                stopInfoLoader.item.searchString = stopIdLong
                stopInfoLoader.item.exactSearch = true
                stopInfoLoader.item.buttonClicked()
            }
            onPushStopToMap: {
                if (tabGroup.currentTab != mapTabButton) initMap("","")
                if (mapLoader.status == Loader.Ready) {
                    mapLoader.item.checkAddStop(stopIdLong_, stopIdShort_, stopName_, stopLongitude_, stopLatitude_)
                }
            }
        }
        Connections {  // stop info
            target: stopInfoLoader.item
            onShowStopMap: {
                console.log("stopInfo signal: showStopMap " + stopIdLong)
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
                }
                tabGroup.lastTab = 0
                mainTabBar.checkedButton = linesTabButton
                tabGroup.currentTab = lineInfoPageContainer
                lineInfoLoader.item.searchString = lineIdLong
                lineInfoLoader.item.buttonClicked()
            }
        }
    }
    function initMap(lineIdLong_, stopIdLong_) { // load map if not yet loaded and show on screen
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
