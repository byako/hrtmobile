import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.systeminfo 1.2
import "database.js" as JS
import "updateDatabase.js" as Updater

Page {
    id: mainPage
    objectName: "mainPage"
    orientationLock: PageOrientation.LockPortrait
    Rectangle{      // dark background
        color: "#000000"
        anchors.fill: parent
    }
    InfoBanner {// info banner
        id: infoBanner
        text: ""
        timerShowTime: 3000
        z: 10
        opacity: 1.0
    }
    Component.onCompleted: {
    }

    QueryDialog {
        id: updateQueryDialog
        acceptButtonText: "Update"
        rejectButtonText: "Later"
        enabled: true
        message: "Some of the routes or timetables have been changed. Database needs to be updated to prevent showing the wrong information"
        titleText: "Database update needed"
        onRejected: {
            console.log("rejected from dialog");
            close();
            favoritesPageItem._init();
        }
        onAccepted: {
            console.log("accepted from dialog");
            close();
            favoritesPageItem._init();
        }
    }

    Loading {          // busy indicator
        id: loading
        visible: false
        message : "Cleaning Database"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        z: 8
    }
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
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search-white" : ""
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
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search-white" : ""
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
                iconSource: (checked) ? "image://theme/icon-m-toolbar-search-white" : ""
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
            Favorites {
                id: favoritesPageItem
            }
        }

        Page {
            id: lineInfoPageContainer
            Loader {
                id: lineInfoLoader
                parent: lineInfoPageContainer
            }
        }
        Page {
            id: stopInfoPageContainer
            Loader {
                id: stopInfoLoader
                parent: stopInfoPageContainer
            }
        }
        Page {
            id: routePageContainer
            Loader {
                id: mapLoader
                parent: routePageContainer
            }
        }
        Page {
            id: settingsPageContainer
            Loader {
                id: settingsLoader
                parent: settingsPageContainer
            }
        }
        Connections {  // favorites
            target: favoritesPageItem
            onFinishedLoad: {
                console.log("loading pages")
                if (lineInfoLoader.status != Loader.Ready) {
                    lineInfoLoader.source = "lineInfo.qml"
                }
                if (stopInfoLoader.status != Loader.Ready) {
                    stopInfoLoader.source = "stopInfo.qml"
                }
                loading.visible = false;
            }
            onLoadStop: {
                console.log("favorites signal: loadStop")
                if (stopInfoLoader.status!= Loader.Ready) {
                    stopInfoLoader.source = "stopInfo.qml"
                }
                tabGroup.lastTab = 1
                mainTabBar.checkedButton = stopsTabButton
                tabGroup.currentTab = stopInfoPageContainer
                stopInfoLoader.item.searchString = stopIdLong
                stopInfoLoader.item.buttonClicked()
            }
            onLoadLine: {
                console.log("favorites signal: loadLine")
                if (lineInfoLoader.status!= Loader.Ready) {
                    lineInfoLoader.source = "lineInfo.qml"
                }
                tabGroup.lastTab = 0
                mainTabBar.checkedButton = linesTabButton
                tabGroup.currentTab = lineInfoPageContainer
                lineInfoLoader.item.searchString = lineIdLong
                lineInfoLoader.item.lineIdLongSearch()
            }
        }
        Connections {  // settings
            target: settingsLoader.item
            onDbclean: {
                console.log("db cleaned: resetting stop and line info pages")
                if (lineInfoLoader.status == Loader.Ready) lineInfoLoader.item.fillModel()
                if (stopInfoLoader.status == Loader.Ready) stopInfoLoader.item.fillModel()
                favoritesPageItem.loadLines()
                favoritesPageItem.loadStops()
            }
            onUpdateConfig: {
                if (lineInfoLoader.status == Loader.Ready) {
                    lineInfoLoader.item.refreshConfig()
                    lineInfoLoader.item.fillModel()
                }
                if (stopInfoLoader.status == Loader.Ready) {
                    stopInfoLoader.item.refreshConfig()
                    stopInfoLoader.item.fillModel()
                }
            }
        }
        Connections {  // map page
            target: mapLoader.item
            onStopInfo: {
                console.log("routePage signal: stopInfo")
                if (stopInfoLoader.status!= Loader.Ready) {
                    stopInfoLoader.source = "stopInfo.qml"
                }
                tabGroup.lastTab = 1
                mainTabBar.checkedButton = stopsTabButton
                tabGroup.currentTab = stopInfoPageContainer
                stopInfoLoader.item.searchString = stopIdLong_
                stopInfoLoader.item.buttonClicked()
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
                stopInfoLoader.item.buttonClicked()
            }
//            onCleanMap: {
//                console.log("lineInfo signal: cleanMapAndPushStops")
//                if(mapLoader.status == Loader.Ready) {
//                    mapLoader.item.cleanStops()
//                } else {
//                    mapLoader.source = "route.qml"
////                    lineInfoLoader.item.sendLineToMap()
//                }
//            }
            onRefreshFavorites: {
                favoritesPageItem.loadLines()
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
                lineInfoLoader.item.lineIdLongSearch()
            }
            onRefreshFavorites: {
                favoritesPageItem.loadStops()
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

        if (lineIdLong_ != "") {
            mapLoader.item.loadStopIdLong = stopIdLong_
            mapLoader.item.loadLine(lineIdLong_)
        } else if (stopIdLong_ != ""){
            mapLoader.item.loadStop(stopIdLong_)
        }
    }
    function showError(errorText) {  // show popup splash window with error
        infoBanner.text = errorText
        infoBanner.show()
    }
    function initPages() {
        console.log("MainPage.qml: init check for reset request")
        if (Updater.resetNeeded()) {
            showError("resetting database")
            console.log("MainPage.qml: cleaning database")
            var temp = Updater.resetDatabase();
            if (temp != 0) {
                console.log("MainPage.qml: DB cleaned")
                showError("Database clean failed:" + temp);
            } else {
                console.log("MainPage.qml: DB clean failed")
                showError("Successfully cleaned database:" + temp);
            }
        } else {
            showError("loading pages")
            favoritesPageItem._init();
        }
        loading.visible = false
    }
}
